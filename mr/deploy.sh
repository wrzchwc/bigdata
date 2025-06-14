#!/bin/bash

CONTAINER_NAME=namenode
LOCAL_PIPELINE_DIR=$(pwd)/mr
CONTAINER_WORKDIR=/home/big-data/map-reduce

docker exec -it $CONTAINER_NAME mkdir -p $CONTAINER_WORKDIR

docker cp $LOCAL_PIPELINE_DIR/pipeline.sh $CONTAINER_NAME:$CONTAINER_WORKDIR/

docker cp $LOCAL_PIPELINE_DIR/mapper_mimic.py $CONTAINER_NAME:$CONTAINER_WORKDIR/
docker cp $LOCAL_PIPELINE_DIR/mapper_gdelt.py $CONTAINER_NAME:$CONTAINER_WORKDIR/
docker cp $LOCAL_PIPELINE_DIR/mapper.py $CONTAINER_NAME:$CONTAINER_WORKDIR/

docker cp $LOCAL_PIPELINE_DIR/reducer_gdelt.py $CONTAINER_NAME:$CONTAINER_WORKDIR/
docker cp $LOCAL_PIPELINE_DIR/reducer.py $CONTAINER_NAME:$CONTAINER_WORKDIR/

docker cp $LOCAL_PIPELINE_DIR/language_station_map.json $CONTAINER_NAME:$CONTAINER_WORKDIR/

docker exec -it $CONTAINER_NAME chmod +x $CONTAINER_WORKDIR/pipeline.sh

docker exec -it -w $CONTAINER_WORKDIR $CONTAINER_NAME ./pipeline.sh