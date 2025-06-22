#!/bin/bash

JAR=big-data_2.12-1.0.jar
CLASS=Pipeline

cd spark
sbt package
docker cp target/scala-2.12/$JAR spark:/opt
docker exec -it spark /opt/spark/bin/spark-submit --class $CLASS --deploy-mode client /opt/$JAR

