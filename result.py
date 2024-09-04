from pyspark.sql import SparkSession
from pyspark.sql.functions import month, year, avg, sum, first, col
from pyspark.sql.functions import coalesce

# Initialize Spark session
spark = SparkSession.builder.appName("RetailAnalytics").enableHiveSupport().getOrCreate()

# Load Data from Hive
sales_data_df = spark.sql("SELECT * FROM dmart.sales_data")
store_data_df = spark.sql("SELECT * FROM dmart.store_data")
features_data_df = spark.sql("SELECT * FROM dmart.features_data_set")

# Define S3 output locations
output_base_path = "s3://resultdmart/retail-analytics/"

# 1. Customer Visit Analysis: Type B Stores in April
type_b_stores_df = store_data_df.filter(col("type") == 'B')
april_sales_df = sales_data_df.join(type_b_stores_df, "store").filter(month(sales_data_df.date) == 4)
average_visits_df = april_sales_df.withColumn("customer_visits", col("weekly_sales") / col("CPI"))
average_visits_result = average_visits_df.groupBy("store").agg(avg("customer_visits").alias("avg_customer_visits"))
average_visits_result.write.mode("overwrite").csv(f"{output_base_path}customer_visit_analysis/")

# 2. Holiday Sales Analysis
holiday_sales_df = sales_data_df.filter(col("isholiday") == 1)
avg_holiday_sales_df = holiday_sales_df.groupBy("store").agg(avg("weekly_sales").alias("avg_sales"))
best_holiday_sales_store = avg_holiday_sales_df.orderBy(col("avg_sales").desc()).limit(1)
best_holiday_sales_store.write.mode("overwrite").csv(f"{output_base_path}holiday_sales_analysis/")

# 3. Leap Year Sales Analysis
leap_year_sales_df = sales_data_df.filter((year(sales_data_df.date) % 4) == 0)
leap_year_sales_result = leap_year_sales_df.groupBy("store").agg(sum("weekly_sales").alias("total_sales"))
worst_sales_store = leap_year_sales_result.orderBy(col("total_sales").asc()).limit(1)
worst_sales_store.write.mode("overwrite").csv(f"{output_base_path}leap_year_sales_analysis/")

# 4. Sales Prediction with Unemployment Factor
high_unemployment_df = features_data_df.filter(col("Unemployment").cast("double") > 8.0)
predicted_sales_df = sales_data_df.join(high_unemployment_df, ["store", "date"], "inner")
predicted_sales_df.write.mode("overwrite").csv(f"{output_base_path}sales_prediction_with_unemployment/")

# 5. Monthly Sales Aggregation
monthly_sales_df = sales_data_df.groupBy("dept", month("date").alias("month")).agg(sum("weekly_sales").alias("total_sales"))
monthly_sales_df.write.mode("overwrite").csv(f"{output_base_path}monthly_sales_aggregation/")

# 6. Weekly High Sales Store Identification
weekly_sales_df = sales_data_df.groupBy("store", "date").agg(sum("weekly_sales").alias("total_sales"))
weekly_high_sales_df = weekly_sales_df.orderBy("date", col("total_sales").desc()).groupBy("date").agg(first("store").alias("top_store"))
weekly_high_sales_df.write.mode("overwrite").csv(f"{output_base_path}weekly_high_sales_store/")

# 7. Department Performance Analysis
dept_performance_df = sales_data_df.groupBy("store", "dept").agg(sum("weekly_sales").alias("total_sales"))
dept_performance_df.write.mode("overwrite").csv(f"{output_base_path}department_performance_analysis/")

# 8. Fuel Price Analysis: Minimum Fuel Price Per Week
min_fuel_price_df = features_data_df.groupBy("store", "date").agg(min("Fuel_Price").alias("min_fuel_price"))
min_fuel_price_per_week = min_fuel_price_df.groupBy("date").agg(first("store").alias("min_fuel_price_store"))
min_fuel_price_per_week.write.mode("overwrite").csv(f"{output_base_path}fuel_price_analysis/")

# 9. Yearly Store Performance Analysis
yearly_performance_df = sales_data_df.groupBy("store", year("date").alias("year")).agg(sum("weekly_sales").alias("total_sales"))
yearly_performance_df.write.mode("overwrite").csv(f"{output_base_path}yearly_store_performance_analysis/")

# 10. Weekly Performance Analysis with/without Offers
# Calculate the total markdown by summing all the markdown columns
features_data_df = features_data_df.withColumn(
    "total_markdown", 
    coalesce(col("MarkDown1").cast("double"), col("MarkDown2").cast("double"), col("MarkDown3").cast("double"),
             col("MarkDown4").cast("double"), col("MarkDown5").cast("double"))
)

# Filter data with offers (total_markdown is not null) and without offers (total_markdown is null)
sales_with_offers_df = sales_data_df.join(features_data_df.filter(col("total_markdown").isNotNull()), ["store", "date"])
sales_without_offers_df = sales_data_df.join(features_data_df.filter(col("total_markdown").isNull()), ["store", "date"])

# Aggregate weekly performance with and without offers
weekly_performance_with_offers_df = sales_with_offers_df.groupBy("store", "date").agg(sum("weekly_sales").alias("total_sales_with_offers"))
weekly_performance_without_offers_df = sales_without_offers_df.groupBy("store", "date").agg(sum("weekly_sales").alias("total_sales_without_offers"))

# Write the results to S3
weekly_performance_with_offers_df.write.mode("overwrite").csv(f"{output_base_path}weekly_performance_with_offers/")
weekly_performance_without_offers_df.write.mode("overwrite").csv(f"{output_base_path}weekly_performance_without_offers/")

# Stop the Spark session
spark.stop()

