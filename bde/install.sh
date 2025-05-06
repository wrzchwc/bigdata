#!/bin/bash

source .env

docker pull bde2020/hadoop-namenode:2.0.0-hadoop2.7.4-java8
docker pull bde2020/hadoop-datanode:2.0.0-hadoop2.7.4-java8

docker-compose -f ./bde/docker-compose.yml -p $PROJECT up -d