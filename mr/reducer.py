#!/usr/bin/env python3

import sys
from collections import defaultdict

current_station = None
gdelt_info = None
group_data = defaultdict(list)  # key -> list of ages

for line in sys.stdin:
    parts = line.strip().split("\t")
    if len(parts) < 3:
        continue

    station, source, *data = parts

    if source == "GDELT":
        gdelt_info = data  # e.g. ['NEWS LIVE - 30', '37043']
    elif source == "MIMIC":
        if gdelt_info is None:
            continue  # skip if no matching show yet

        try:
            sex = data[0]
            age = int(data[1])
            group_key = tuple([station] + gdelt_info + data[2:])  # exclude age
            group_data[group_key].append(age)
        except Exception:
            continue  # skip malformed lines

# Emit group and average age
for group_key, ages in group_data.items():
    avg_age = sum(ages) / len(ages)
    output = list(group_key)
    output.insert(3, f"{avg_age:.2f}")  # insert avg_age at the position of age
    print("\t".join(str(x) for x in output))