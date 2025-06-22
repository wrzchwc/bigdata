DROP TABLE IF EXISTS gdelt_station_summary;
DROP TABLE IF EXISTS mimic_station_summary;
DROP TABLE IF EXISTS gdelt;
DROP TABLE IF EXISTS mimic;
DROP TABLE IF EXISTS language_station_map;

SET hive.auto.convert.join = false;

CREATE EXTERNAL TABLE mimic (
    subject_id BIGINT,
    hadm_id BIGINT,
    icd_code STRING,
    icd_version TINYINT,
    gender CHAR(1),
    anchor_age TINYINT,
    anchor_year_group STRING,
    admission_type STRING,
    admission_location STRING,
    discharge_location STRING,
    insurance STRING,
    language STRING,
    martial_status STRING,
    race STRING,
    edregtime TIMESTAMP,
    edouttime TIMESTAMP
)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
STORED AS TEXTFILE
LOCATION '/project/mimic';

CREATE EXTERNAL TABLE gdelt (
    URL STRING,
    MatchDate DATE,
    Station STRING,
    Show STRING,
    IAShowID STRING,
    IAPreview STRING,
    Snippet STRING,
    MatchDateTimeStamp TIMESTAMP
)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
STORED AS TEXTFILE
LOCATION '/project/gdelt';

CREATE EXTERNAL TABLE language_station (
    language STRING,
    station STRING
)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
STORED AS TEXTFILE
LOCATION '/project/other';

CREATE TABLE map_mimic AS
SELECT gender, anchor_age, admission_type, admission_location, discharge_location, insurance, language, martial_status, race
FROM mimic
WHERE anchor_year_group = '2020 - 2022';

CREATE TABLE map_reduce_gdelt AS
WITH show_counts AS (
  SELECT Station, Show, COUNT(*) AS show_count
  FROM gdelt
  GROUP BY Station, Show
),
ranked_shows AS (
  SELECT Station, Show, show_count, ROW_NUMBER() OVER (PARTITION BY Station ORDER BY show_count DESC) AS rn
  FROM show_counts
)
SELECT Station, Show, show_count FROM ranked_shows
WHERE rn = 1;

CREATE TABLE join_mimic_plus_gdelt AS
SELECT m.gender, m.anchor_age, m.admission_type, m.admission_location, m.discharge_location, m.insurance, m.language, m.martial_status, m.race, l.station
FROM map_mimic m
INNER JOIN language_station l
ON m.language = l.language;

CREATE TABLE final_reduction_and_aggregation AS
SELECT m.Station, m.Show, m.show_count, ROUND(AVG(j.anchor_age), 2) AS avg_age, j.admission_type, j.admission_location, j.discharge_location, j.insurance, j.language, j.martial_status, j.race
FROM join_mimic_plus_gdelt j
INNER JOIN map_reduce_gdelt m
ON j.station = m.station
GROUP BY m.Station, m.Show, m.show_count, j.admission_type, j.admission_location, j.discharge_location, j.insurance, j.language, j.martial_status, j.race;