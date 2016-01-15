#!/bin/bash

: ${HADOOP_PREFIX:=/usr/local/hadoop}
: ${ZOO_HOME:=/usr/local/zookeeper}
: ${HBASE_HOME:=/usr/local/hbase}
: ${M2_HOME:=/usr/local/maven}

PHOENIX_VERSION="4.7.0-HBase-1.1-SNAPSHOT"
echo "Building Phoenix master branch"
curl -s -L https://github.com/apache/phoenix/archive/master.tar.gz | tar -xz -C /usr/local/
cd /usr/local/phoenix-master && mvn package -DskipTests -Dcalcite.version=1.6.0-SNAPSHOT
echo "Extracting Phoenix tarball"
tar xf /usr/local/phoenix-master/phoenix-assembly/target/phoenix-${PHOENIX_VERSION}.tar.gz -C /usr/local
ln -s /usr/local/phoenix-$PHOENIX_VERSION /usr/local/phoenix
PHOENIX_HOME="/usr/local/phoenix"
echo "Replacing Phoenix jars"
rm $HBASE_HOME/lib/phoenix-server.jar
ln -s $PHOENIX_HOME/phoenix-4.7.0-HBase-1.1-SNAPSHOT-server.jar $HBASE_HOME/lib/phoenix-server.jar

rm /tmp/*.pid

# installing libraries if any - (resource urls added comma separated to the ACP system variable)
cd $HADOOP_PREFIX/share/hadoop/common ; for cp in ${ACP//,/ }; do  echo == $cp; curl -LO $cp ; done; cd -

service sshd start
$HADOOP_PREFIX/sbin/start-dfs.sh
#$HADOOP_PREFIX/sbin/start-yarn.sh
$HBASE_HOME/bin/start-hbase.sh

if [[ $1 == "-sqlline" ]]; then
  /usr/local/phoenix/bin/sqlline-thin.py http://localhost:8765
else
  echo "Starting queryserver"
  /usr/local/phoenix/bin/queryserver.py
fi
