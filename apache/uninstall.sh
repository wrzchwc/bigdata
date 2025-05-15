#!/bin/bash

source ./apache/.env

docker-compose -p $PROJECT down --volumes