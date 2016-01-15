FROM sequenceiq/hadoop-docker:2.7.0
MAINTAINER SequenceIQ

# Zookeeper
ENV ZOOKEEPER_VERSION 3.4.6
RUN curl -s http://mirror.csclub.uwaterloo.ca/apache/zookeeper/zookeeper-$ZOOKEEPER_VERSION/zookeeper-$ZOOKEEPER_VERSION.tar.gz | tar -xz -C /usr/local/
RUN cd /usr/local && ln -s ./zookeeper-$ZOOKEEPER_VERSION zookeeper
ENV ZOO_HOME /usr/local/zookeeper
ENV PATH $PATH:$ZOO_HOME/bin
RUN mv $ZOO_HOME/conf/zoo_sample.cfg $ZOO_HOME/conf/zoo.cfg
RUN mkdir /tmp/zookeeper

# HBase
ENV HBASE_MAJOR 1.1
ENV HBASE_MINOR 2
ENV HBASE_VERSION "${HBASE_MAJOR}.${HBASE_MINOR}"
RUN	if [ $HBASE_MAJOR == 0.98 ]; then \
		curl -s http://apache.mirror.gtcomm.net/hbase/$HBASE_VERSION/hbase-$HBASE_VERSION-hadoop2-bin.tar.gz | tar -xz -C /usr/local/ && \
		cd /usr/local && ln -s ./hbase-$HBASE_VERSION-hadoop2 hbase; \
	elif [ $HBASE_MAJOR == 1.0 ]; then \
		curl -s http://apache.mirror.gtcomm.net/hbase/hbase-$HBASE_VERSION/hbase-$HBASE_VERSION-bin.tar.gz | tar -xz -C /usr/local/ && \
		cd /usr/local && ln -s ./hbase-$HBASE_VERSION hbase; \
	else \
		curl -s http://apache.mirror.gtcomm.net/hbase/$HBASE_VERSION/hbase-$HBASE_VERSION-bin.tar.gz | tar -xz -C /usr/local/ && \
		cd /usr/local && ln -s ./hbase-$HBASE_VERSION hbase; \
	fi
ENV HBASE_HOME /usr/local/hbase
ENV PATH $PATH:$HBASE_HOME/bin

# Maven
ENV MAVEN_VERSION 3.3.9
RUN curl -s http://mirror.reverse.net/pub/apache/maven/maven-3/3.3.9/binaries/apache-maven-3.3.9-bin.tar.gz | tar -xz -C /usr/local/
RUN ln -s /usr/local/apache-maven-$MAVEN_VERSION /usr/local/maven
ENV M2_HOME /usr/local/maven
ENV PATH $PATH:$M2_HOME/bin

# Phoenix
#ENV PHOENIX_VERSION 4.6.0
#RUN curl -s http://apache.mirror.vexxhost.com/phoenix/phoenix-$PHOENIX_VERSION-HBase-$HBASE_MAJOR/bin/phoenix-$PHOENIX_VERSION-HBase-$HBASE_MAJOR-bin.tar.gz | tar -xz -C /usr/local/
#RUN cd /usr/local && ln -s ./phoenix-$PHOENIX_VERSION-HBase-$HBASE_MAJOR-bin phoenix
#ENV PHOENIX_HOME /usr/local/phoenix
#ENV PATH $PATH:$PHOENIX_HOME/bin
#RUN ln -s $PHOENIX_HOME/phoenix-core-$PHOENIX_VERSION-HBase-$HBASE_MAJOR.jar $HBASE_HOME/lib/phoenix.jar
#RUN ln -s $PHOENIX_HOME/phoenix-$PHOENIX_VERSION-HBase-$HBASE_MAJOR-server.jar $HBASE_HOME/lib/phoenix-server.jar

ENV PHOENIX_VERSION 4.7.0-HBase-1.1-SNAPSHOT
RUN curl -s -L https://github.com/apache/phoenix/archive/master.tar.gz | tar -xz -C /usr/local/
RUN cd /usr/local/phoenix-master && mvn package -DskipTests -Dcalcite.version=1.6.0-SNAPSHOT
RUN tar xf /usr/local/phoenix-master/phoenix-assembly/target/phoenix-4.7.0-HBase-1.1-SNAPSHOT.tar.gz -C /usr/local
RUN ln -s /usr/local/phoenix-$PHOENIX_VERSION /usr/local/phoenix
ENV PHOENIX_HOME /usr/local/phoenix
RUN ln -s $PHOENIX_HOME/phoenix-4.7.0-HBase-1.1-SNAPSHOT-server.jar $HBASE_HOME/lib/phoenix-server.jar

# HBase and Phoenix configuration files
RUN rm $HBASE_HOME/conf/hbase-site.xml
RUN rm $HBASE_HOME/conf/hbase-env.sh
ADD hbase-site.xml $HBASE_HOME/conf/hbase-site.xml
ADD hbase-env.sh $HBASE_HOME/conf/hbase-env.sh

# bootstrap-phoenix
ADD bootstrap-phoenix.sh /etc/bootstrap-phoenix.sh
RUN chown root:root /etc/bootstrap-phoenix.sh
RUN chmod 700 /etc/bootstrap-phoenix.sh

CMD ["/etc/bootstrap-phoenix.sh", "-bash"]

# expose Zookeeper and Phoenix queryserver ports
EXPOSE 2181 8765
