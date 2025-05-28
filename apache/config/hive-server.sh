#!/bin/bash

echo "Waiting for Namenode to be fully functional and HDFS /tmp permissions to be correct..."
          
until hdfs dfsadmin -safemode get | grep -q 'OFF' && \
    hdfs dfs -ls / | grep 'tmp' | grep -q '^drwxrwxrwt'; do
echo "Namenode or /tmp permissions not ready. Retrying in 10s..."
sleep 10;
done;

echo "Namenode is ready and /tmp permissions are correct. Ensuring Hive-specific HDFS paths..."

hdfs dfs -mkdir -p /tmp || true
hdfs dfs -chmod 1777 /tmp
hdfs dfs -mkdir -p /user/hive || true
hdfs dfs -chown hive:hive /user/hive
hdfs dfs -chmod -R 777 /user/hive

echo "HDFS setup for HiveServer2 complete. Starting HiveServer2..."
exec java ${JAVA_OPTS} \
-Dhive.conf.dir=/opt/hive/conf \
-Dlog4j.configuration=file:///opt/hive/conf/log4j.properties \
-classpath "/opt/hive/lib/*:/opt/hadoop/etc/hadoop:/opt/hadoop/share/hadoop/common/*:/opt/hadoop/share/hadoop/common/lib/*:/opt/hadoop/share/hadoop/hdfs/*:/opt/hadoop/share/hadoop/hdfs/lib/*:/opt/hadoop/share/hadoop/mapreduce/*:/opt/hadoop/share/hadoop/mapreduce/lib/*:/opt/hadoop/share/hadoop/yarn/*:/opt/hadoop/share/hadoop/yarn/lib/*:/opt/tez/*:/opt/tez/lib/*" \
org.apache.hive.service.server.HiveServer2