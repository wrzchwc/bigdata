#!/bin/bash

source .env

docker-compose -f ./apache/docker-compose.yml -p $PROJECT up -d