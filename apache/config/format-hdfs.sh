#!/bin/bash
set -e

NAMEDIR="/hadoop/dfs/name"

if [ ! -f "$NAMEDIR/current/VERSION" ]; then
  hdfs namenode -format -nonInteractive

  hdfs namenode > /tmp/namenode.log 2>&1 &
  NAMENODE_PID=$!

  until hdfs dfsadmin -safemode get | grep -q 'OFF'; do
    sleep 2
  done

  hdfs dfs -mkdir -p /mr-history/tmp
  hdfs dfs -mkdir -p /mr-history/done
  hdfs dfs -chmod -R 1777 /mr-history
  hdfs dfs -chown -R mapred:hadoop /mr-history
  hdfs dfs -mkdir -p /user/hive/warehouse
  hdfs dfs -chmod -R 1777 /user/hive/warehouse


  kill $NAMENODE_PID
  wait $NAMENODE_PID || true
  sleep 5
fi

exec hdfs namenode