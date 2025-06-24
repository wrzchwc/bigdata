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

    val phase1 = logDuration("Map MIMIC")(mapMimic(mimicDF).persist())
    val phase2 = logDuration("MapReduce GDELT")(mapReduceGdelt(gdeltDF))
    val phase3 = logDuration("Join MIMIC + GDELT")(joinMimicPlusGdelt(phase1, spark))
    phase1.unpersist()
    val phase4 = logDuration("Final Reduction & Aggregation")(finalReductionAndAggregation(phase2, phase3))

    phase4.write
      .option("header", "true")
      .mode("overwrite")
      .csv("hdfs:///user/spark/output")

    spark.stop()
  }

   def logDuration[T](label: String)(block: => T): T = {
    val start = System.nanoTime()
    val result = block
    val end = System.nanoTime()
    println(s"TIMELOG: $label: ${(end - start) / 1e9} s")
    result
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
      .join(langMapDF, Seq("language"), "left")
      .withColumn("Station", coalesce(col("station"), lit("CNN")))
  }

  def finalReductionAndAggregation(dataFrame2: DataFrame, dataFrame3: DataFrame): DataFrame = {
    dataFrame2
      .join(dataFrame3, Seq("Station"))
      .groupBy(
        "Station",
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