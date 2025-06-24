# Pliki konfiguracyjne
- `apache/config/core-site.xml` - definiuje podstawowe ustawienia Hadoop, takie jak domyślny system plików (fs.defaultFS), co pozwala systemowi odnaleźć główne miejsce przechowywania danych, np. HDFS.
- `apache/config/hdfs-site.xml` - zawiera konfiguracje specyficzne dla HDFS, takie jak rozmiar bloku, współczynnik replikacji czy katalogi przechowywania, określające sposób zarządzania i przechowywania danych w klastrze Hadoop.

# Czasy trwania etapów potoku przetwarzania
Czasy podano w milisekundach.

|Etap|MR|HIVE|Spark|
|----|-------|---|---|
|`Map MIMIC`|57000|81000|152|
|`MapReduce GDELT`|65000|121000|222|
|`Join MIMIC + GDELT`|33000|66000|806|
|`Final Reduction & Aggregation`|32000|86000|18|