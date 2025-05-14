#!/usr/bin/env python3

import sys
import csv

reader = csv.reader(sys.stdin)

for fields in reader:
    if fields[0] == "subject_id":
        continue
    try:
        if fields[6].strip() == "2020 - 2022":
            output = [
                fields[4],  # gender
                fields[5],  # anchor_age
                fields[7],  # admission_type
                fields[8],  # admission_location
                fields[9],  # discharge_location
                fields[10], # insurance
                fields[11], # language
                fields[12], # marital_status
                fields[13]  # race
            ]
            print("\t".join(output))
    except Exception:
        continue