#!/bin/bash

source ./data/.env

LOCAL_DIR="/tmp/bigdata_acquisition"
LOGFILE="acquisition.log"
CONTAINER_NAME="namenode"

mkdir -p "$LOCAL_DIR"
echo "[`date`] Data acquisition started" >> "$LOGFILE"

if gsutil cp "$BUCKET/mimic_data.csv" "$LOCAL_DIR/"; then
  echo "[`date`] mimic_data.csv downloaded" >> "$LOGFILE"
else
  echo "[`date`] mimic_data.csv download FAILED" >> "$LOGFILE"
fi

if gsutil cp "$BUCKET/gdelt_data.csv" "$LOCAL_DIR/"; then
  echo "[`date`] gdelt_data.csv downloaded" >> "$LOGFILE"
else
  echo "[`date`] gdelt_data.csv download FAILED" >> "$LOGFILE"
fi

if docker cp "$LOCAL_DIR" "$CONTAINER_NAME:/tmp/"; then
  echo "[`date`] all data copied to container" >> "$LOGFILE"
else
  echo "[`date`] docker cp FAILED" >> "$LOGFILE"
fi

docker exec -i "$CONTAINER_NAME" bash <<EOF
echo "[\$(date)] HDFS operations started"

hdfs dfs -mkdir -p /project/mimic
echo "[\$(date)] MIMIC directory created"

hdfs dfs -mkdir -p /project/gdelt
echo "[\$(date)] GDELT directory created"

if hdfs dfs -put -f /tmp/bigdata_acquisition/mimic_data.csv /project/mimic/; then
  echo "[\$(date)] mimic_data.csv saved to HDFS"
else
  echo "[\$(date)] mimic_data.csv HDFS upload FAILED"
fi

if hdfs dfs -put -f /tmp/bigdata_acquisition/gdelt_data.csv /project/gdelt/; then
  echo "[\$(date)] gdelt_data.csv saved to HDFS"
else
  echo "[\$(date)] gdelt_data.csv HDFS upload FAILED"
fi

hdfs dfs -setrep -w 3 /project/mimic/mimic_data.csv
hdfs dfs -setrep -w 3 /project/gdelt/gdelt_data-*.csv

echo "[\$(date)] HDFS operations completed"
EOF

rm -rf "$LOCAL_DIR"
echo "[`date`] Temporary files in $LOCAL_DIR removed" >> "$LOGFILE"

echo "[`date`] Data acquisition completed" >> "$LOGFILE"