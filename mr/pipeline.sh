#!/bin/bash

LOGFILE="job_timing.log"

HADOOP_STREAMING_JAR=/hadoop/hadoop-dist/target/hadoop-3.5.0-SNAPSHOT/share/hadoop/tools/lib/hadoop-streaming-3.5.0-SNAPSHOT.jar

INPUT_MIMIC=/project/mimic/mimic_data.csv
INPUT_GDELT=/project/gdelt/gdelt_data.csv

TMP1_OUT=/tmp/tmp1
TMP2_OUT=/tmp/tmp2
TMP3_OUT=/tmp/tmp3
FINAL_OUT=/output/final

hdfs dfs -rm -r -f $TMP1_OUT $TMP2_OUT $TMP3_OUT $FINAL_OUT

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] START $1" >> $LOGFILE
  START_TIME=$(date +%s)

  eval "$2"

  END_TIME=$(date +%s)
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] END $1 - Duration: $((END_TIME - START_TIME))s" >> $LOGFILE
  echo "" >> $LOGFILE
}

log "Map MIMIC" \
  "hadoop jar $HADOOP_STREAMING_JAR \
    -input $INPUT_MIMIC \
    -output $TMP1_OUT \
    -mapper mapper_mimic.py \
    -reducer cat \
    -file mapper_mimic.py"

log "MapReduce GDELT" \
  "hadoop jar $HADOOP_STREAMING_JAR \
    -input $INPUT_GDELT \
    -output $TMP2_OUT \
    -mapper mapper_gdelt.py \
    -reducer reducer_gdelt.py \
    -file mapper_gdelt.py \
    -file reducer_gdelt.py"

log "Join MIMIC + GDELT" \
  "hadoop jar $HADOOP_STREAMING_JAR \
    -input $TMP1_OUT \
    -input $TMP2_OUT \
    -output $TMP3_OUT \
    -mapper mapper.py \
    -reducer cat \
    -file mapper.py \
    -file language_station_map.json"

log "Final Reduction & Aggregation" \
  "hadoop jar $HADOOP_STREAMING_JAR \
    -input $TMP3_OUT \
    -output $FINAL_OUT \
    -mapper cat \
    -reducer reducer.py \
    -file reducer.py"

hdfs dfs -cat $FINAL_OUT/part-* | head -n 10