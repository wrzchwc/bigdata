#!/usr/bin/env python3

import sys
from collections import defaultdict

station_show_counts = defaultdict(lambda: defaultdict(int))

for line in sys.stdin:
    line = line.strip()
    if not line:
        continue
    try:
        station, show, count_str = line.split("\t")
        count = int(count_str)
        station_show_counts[station][show] += count
    except ValueError:
        continue

for station, shows in station_show_counts.items():
    top_show, top_count = max(shows.items(), key=lambda item: item[1])
    print(f"{station}\t{top_show}\t{top_count}")