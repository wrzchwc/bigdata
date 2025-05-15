#!/bin/bash

source ./data/.env

DATASET="big_data"

bq extract --destination_format=CSV "$DATASET.mimic" "$BUCKET/mimic_data.csv"
bq extract --destination_format=CSV "$DATASET.gdelt" "$BUCKET/gdelt_data.csv"