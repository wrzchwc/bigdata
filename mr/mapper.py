#!/usr/bin/env python3

import sys
import json

with open("language_station_map.json") as f:
    language_to_station = json.load(f)

for line in sys.stdin:
    line = line.strip()
    if not line or line.startswith("WARN"):
        continue

    fields = line.split("\t")

    if len(fields) >= 8 and fields[6] in language_to_station:
        language = fields[6]
        station = language_to_station.get(language, "CNN")
        print(f"{station}\tMIMIC\t{line}")
    elif len(fields) == 3:
        station, show, count = fields
        print(f"{station}\tGDELT\t{show}\t{count}")