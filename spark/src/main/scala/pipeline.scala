import org.apache.spark.sql.SparkSession
import org.apache.spark.sql.DataFrame
import org.apache.spark.sql.functions._
import org.apache.spark.sql.expressions.Window

object Pipeline {
  def main(args: Array[String]): Unit = {
    val spark = SparkSession.builder()
      .appName("Pipeline")
      .master("yarn")
      .getOrCreate()
        
    val mimicDF = spark.read
      .option("header", "true")
      .option("inferSchema", "true")
      .csv("hdfs:///project/mimic")
    val gdeltDF = spark.read
      .option("header", "true")
      .option("inferSchema", "true")
      .csv("hdfs:///project/gdelt")

    val phase1 = mapMimic(mimicDF)
    val phase2 = mapReduceGdelt(gdeltDF)
    val phase3 = joinMimicPlusGdelt(phase1, spark)
    val phase4 = finalReductionAndAggregation(phase2, phase3)

    phase4.write
      .option("header", "true")
      .csv("hdfs:///output/most_watched_by_group")

    spark.stop()
  }

  def mapMimic(dataFrame: DataFrame): DataFrame  = {
    dataFrame
      .filter(col("language").isNotNull)
      .filter(col("anchor_year_group") ===  "2020 - 2022")
      .select(
        "anchor_age",
        "admission_type",
        "admission_location",
        "discharge_location",
        "insurance",
        "language",
        "marital_status",
        "race"
      )
  }

  def mapReduceGdelt(dataFrame: DataFrame): DataFrame = {
    dataFrame
      .withColumn("year", year(to_timestamp(col("MatchDateTimeStamp"))))
      .filter(col("year").between(2020, 2022))
      .groupBy(col("Station"), col("Show"))
      .count()
      .withColumn("rank", row_number().over(
        Window.partitionBy("Station").orderBy(desc("count"))
      ))
      .filter(col("rank") === 1)
      .drop("rank", "year")
  }

  def joinMimicPlusGdelt(dataFrame: DataFrame, session: SparkSession): DataFrame = {
    val langMapDF = session.read
      .option("header", "false")
      .csv("hdfs:///project/other/language_map.csv")
      .toDF("language", "station")
    dataFrame
      .join(langMapDF, dataFrame("language") === langMapDF("language"), "left")
      .withColumn("station", coalesce(col("station"), lit("CNN")))
  }

  def finalReductionAndAggregation(dataFrame2: DataFrame, dataFrame3: DataFrame): DataFrame = {
    dataFrame2
      .join(dataFrame3, dataFrame2("language") === dataFrame3("language"))
      .groupBy(
        "station", 
        "Show", 
        "count", 
        "admission_type", 
        "admission_location",
        "discharge_location",
        "insurance",
        "language",
        "marital_status",
        "race"
      )
      .agg(avg("anchor_age").as("average_age"))
  }
}