import org.apache.spark.sql.SparkSession

object Pipeline {
  def main(args: Array[String]): Unit = {
    val spark = SparkSession.builder()
      .appName("Pipeline")
      .master("yarn")
      .getOrCreate()

    spark.stop()
  }
}