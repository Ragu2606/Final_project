from pyspark.sql import SparkSession
import logging
from pyspark.sql.functions import col, when, to_date
from py4j.java_gateway import java_import

logging.basicConfig(level=logging.INFO)

try:
    # Initialize Spark session with Hive support and necessary configurations
    spark = SparkSession.builder \
        .appName("CleanAndPushToHive") \
        .config("spark.sql.warehouse.dir", "/user/hive/warehouse") \
        .config("hive.metastore.uris", "thrift://localhost:9083") \
        .config("hive.exec.dynamic.partition", "true") \
        .config("hive.exec.dynamic.partition.mode", "nonstrict") \
        .enableHiveSupport() \
        .getOrCreate()
    # Access Hadoop FileSystem to modify permissions
hadoop_conf = spark._jsc.hadoopConfiguration()
fs = spark._jvm.org.apache.hadoop.fs.FileSystem.get(hadoop_conf)

# Set the permission (755 for directories)
permission = spark._jvm.org.apache.hadoop.fs.permission.FsPermission("755")
fs.setPermission(spark._jvm.org.apache.hadoop.fs.Path('/user/hadoop/features_data'), permission)

# Load data from HDFS
df = spark.read.csv('/user/hadoop/features_data/Features_data_set.csv', header=True, inferSchema=True)

# Data cleaning operations
# Convert date format from 'dd/MM/yyyy' to 'yyyy-MM-dd'
df = df.withColumn('Date', to_date(col('Date'), 'dd/MM/yyyy'))

# Convert 'IsHoliday' from FALSE/TRUE to 0/1
df = df.withColumn('IsHoliday', when(col('IsHoliday') == 'TRUE', 1).otherwise(0))

# Drop duplicates
df_cleaned = df.dropDuplicates()

# Fill missing values
df_cleaned = df_cleaned.fillna({
    'MarkDown1': None,
    'MarkDown2': None,
    'MarkDown3': None,
    'MarkDown4': None,
    'MarkDown5': None
})

# Save to Hive
spark.sql("CREATE DATABASE IF NOT EXISTS dmart")
spark.sql("USE dmart")
df_cleaned.write.mode('overwrite').saveAsTable('Features_data_set')

# Verify data
spark.sql("SELECT * FROM dmart.Features_data_set").show()

