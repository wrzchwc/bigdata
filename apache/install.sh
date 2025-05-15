#!/bin/bash

source ./apache/.env

docker-compose -f ./apache/docker-compose.yml -p $PROJECT up -d