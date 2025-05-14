#!/usr/bin/env python3

import sys
import csv

reader = csv.reader(sys.stdin)

for fields in reader:
    if fields[0] == "URL":
        continue
    try:
        year = fields[7].strip()[:4]
        if "2020" <= year <= "2022":
            station = fields[2].strip()
            show = fields[3].strip()
            if station and show:
                print(f"{station}\t{show}\t1")
    except Exception:
        continue