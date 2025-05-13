#!/bin/bash

GCS_BUCKET="gs://hadoop-pwr"
LOCAL_DIR="/tmp/bigdata_acquisition"
LOGFILE="acquisition.log"
MIMIC_TABLE="big_data.mimic"
GDELT_TABLE="big_data.gdelt"
CONTAINER_NAME="namenode"

mkdir -p "$LOCAL_DIR"
echo "[`date`] Data acquisition started" >> "$LOGFILE"

if bq extract --destination_format=CSV "$MIMIC_TABLE" "$GCS_BUCKET/mimic_data.csv"; then
  echo "[`date`] mimic_data.csv export successful" >> "$LOGFILE"
else
  echo "[`date`] mimic_data.csv export FAILED" >> "$LOGFILE"
fi

if bq extract --destination_format=CSV "$GDELT_TABLE" "$GCS_BUCKET/gdelt_data-*.csv"; then
  echo "[`date`] gdelt_data export successful (sharded)" >> "$LOGFILE"
else
  echo "[`date`] gdelt_data export FAILED" >> "$LOGFILE"
fi

if gsutil cp "$GCS_BUCKET/mimic_data.csv" "$LOCAL_DIR/"; then
  echo "[`date`] mimic_data.csv downloaded" >> "$LOGFILE"
else
  echo "[`date`] mimic_data.csv download FAILED" >> "$LOGFILE"
fi

if gsutil cp "$GCS_BUCKET/gdelt_data-*.csv" "$LOCAL_DIR/"; then
  echo "[`date`] gdelt_data shards downloaded" >> "$LOGFILE"
else
  echo "[`date`] gdelt_data download FAILED" >> "$LOGFILE"
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

FILES=\$(ls /tmp/bigdata_acquisition/gdelt_data-*.csv 2>/dev/null | wc -l)

if [ "\$FILES" -eq 0 ]; then
  echo "[\$(date)] No GDELT files found in /tmp/bigdata_acquisition"
else
  for f in /tmp/bigdata_acquisition/gdelt_data-*.csv; do
    echo "[\$(date)] Uploading \$f to HDFS..."
    if hdfs dfs -D dfs.blocksize=16m -put -f "\$f" /project/gdelt/; then
      echo "[\$(date)] Uploaded \$f"
    else
      echo "[\$(date)] FAILED to upload \$f"
    fi
  done
fi

hdfs dfs -setrep -w 3 /project/mimic/mimic_data.csv
hdfs dfs -setrep -w 3 /project/gdelt/gdelt_data-*.csv

echo "[\$(date)] HDFS operations completed"
EOF

rm -rf "$LOCAL_DIR"
echo "[`date`] Temporary files in $LOCAL_DIR removed" >> "$LOGFILE"

echo "[`date`] Data acquisition completed" >> "$LOGFILE"