# Pliki konfiguracyjne
- `apache/config/core-site.xml` - definiuje podstawowe ustawienia Hadoop, takie jak domyślny system plików (fs.defaultFS), co pozwala systemowi odnaleźć główne miejsce przechowywania danych, np. HDFS.
- `apache/config/hdfs-site.xml` - zawiera konfiguracje specyficzne dla HDFS, takie jak rozmiar bloku, współczynnik replikacji czy katalogi przechowywania, określające sposób zarządzania i przechowywania danych w klastrze Hadoop.

# Czasy trwania etapów map-reduce
|Etap|Czas [s]|
|----|-------|
|`Map MIMIC`| 13|
|`MapReduce GDELT`| 12|
|`Join MIMIC + GDELT` | 4 |
|`Final Reduction & Aggregation`| 4|