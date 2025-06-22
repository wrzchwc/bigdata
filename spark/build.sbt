ThisBuild / scalaVersion := "2.12.18"

name := "big-data"
version := "1.0" 

libraryDependencies ++= Seq(
  "org.apache.spark" %% "spark-core" % "3.3.2",
  "org.apache.spark" %% "spark-sql" % "3.3.2"
)