# Pliki konfiguracyjne
- `apache/config/core-site.xml` - definiuje podstawowe ustawienia Hadoop, takie jak domyślny system plików (fs.defaultFS), co pozwala systemowi odnaleźć główne miejsce przechowywania danych, np. HDFS.
- `apache/config/hdfs-site.xml` - zawiera konfiguracje specyficzne dla HDFS, takie jak rozmiar bloku, współczynnik replikacji czy katalogi przechowywania, określające sposób zarządzania i przechowywania danych w klastrze Hadoop.

# Czasy trwania etapów potoku przetwarzania
Czasy podano w sekundach.

|Etap|MR|HIVE|
|----|-------|---|
|`Map MIMIC`|57|111|
|`MapReduce GDELT`|65|145|
|`Join MIMIC + GDELT`|33|79|
|`Final Reduction & Aggregation`|32|109|