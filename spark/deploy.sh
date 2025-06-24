#!/bin/bash

JAR=big-data_2.12-1.0.jar
CLASS=Pipeline

cd spark
sbt package
docker exec -it spark hdfs dfs -rm -r -f /user/spark/.sparkStaging/*
docker cp target/scala-2.12/$JAR spark:/opt
docker exec -it spark /opt/spark/bin/spark-submit --class $CLASS --deploy-mode client  --executor-memory 512m --driver-memory 512m /opt/$JAR

