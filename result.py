from pyspark.sql import SparkSession
from pyspark.sql.functions import month, year, avg, sum, first, col, coalesce, lit, count, min

# Initialize Spark session
spark = SparkSession.builder.appName("RetailAnalytics").enableHiveSupport().getOrCreate()

# Load Data from Hive
sales_data_df = spark.sql("SELECT * FROM dmart.sales_data")
store_data_df = spark.sql("SELECT * FROM dmart.store_data")
features_data_df = spark.sql("SELECT * FROM dmart.features_data_set")

# Define S3 output location
output_path = "s3://resultdmart/retail-analytics/"

# 1. Customer Visit Analysis: Type B Stores in April
type_b_stores_df = store_data_df.filter(col("type") == 'B')
sales_with_cpi_df = sales_data_df.join(features_data_df, ["store", "date"])
april_sales_df = sales_with_cpi_df.join(type_b_stores_df, "store").filter(month(sales_with_cpi_df.date) == 4)
average_visits_df = april_sales_df.withColumn("customer_visits", col("weekly_sales") / col("cpi"))
average_visits_result = average_visits_df.groupBy("store").agg(avg("customer_visits").alias("avg_customer_visits"))
average_visits_result = average_visits_result.orderBy(col("avg_customer_visits").desc())

# Show result
average_visits_result.show()

# 2. Holiday Sales Analysis
holiday_sales_df = sales_data_df.filter(col("isholiday") == 1)
avg_holiday_sales_df = holiday_sales_df.groupBy("store").agg(avg("weekly_sales").alias("avg_sales"))
best_holiday_sales_store = avg_holiday_sales_df.orderBy(col("avg_sales").desc())

# Show result
best_holiday_sales_store.show()

# 3. Leap Year Sales Analysis
leap_year_sales_df = sales_data_df.filter((year(sales_data_df.date) % 4) == 0)
leap_year_sales_result = leap_year_sales_df.groupBy("store").agg(sum("weekly_sales").alias("total_sales"))
worst_sales_store = leap_year_sales_result.orderBy(col("total_sales").asc())

# Show result
worst_sales_store.show()

# 4. Sales Prediction with Unemployment Factor
high_unemployment_df = features_data_df.filter(col("Unemployment").cast("double") >= 8.0)
sales_with_unemployment_df = sales_data_df.join(high_unemployment_df, ["store", "date"], "inner")
predicted_sales_df = sales_with_unemployment_df.groupBy("store", "dept", "Unemployment") \
    .agg(avg("weekly_sales").alias("avg_weekly_sales"))
predicted_sales_sorted_df = predicted_sales_df.orderBy(col("Unemployment").desc(), "store", "dept", "avg_weekly_sales")
predicted_sales_result = predicted_sales_sorted_df.select("Unemployment", "store", "dept", "avg_weekly_sales")

# Show result
predicted_sales_result.show()


# 5. Monthly Sales Aggregation
monthly_sales_df = sales_data_df.groupBy("dept", month("date").alias("month")).agg(sum("weekly_sales").alias("total_sales"))
monthly_sales_df = monthly_sales_df.orderBy("dept", "month")

# Show result
monthly_sales_df.show()

# 6. Weekly High Sales Store Identification
weekly_sales_df = sales_data_df.groupBy("store", "date").agg(sum("weekly_sales").alias("total_sales"))
weekly_high_sales_df = weekly_sales_df.orderBy("date", col("total_sales").desc()) \
    .groupBy("date").agg(first("store").alias("top_store"))
top_store_count_df = weekly_high_sales_df.groupBy("top_store").agg(count("date").alias("weeks_as_top_store"))
top_store_count_df = top_store_count_df.orderBy(col("weeks_as_top_store").desc())

# Show result
top_store_count_df.show()

# 7. Department Performance Analysis
dept_performance_df = sales_data_df.groupBy("store", "dept").agg(sum("weekly_sales").alias("total_sales"))
dept_performance_df = dept_performance_df.orderBy(col("total_sales").desc())

# Show result
dept_performance_df.show()

# 8. Fuel Price Analysis: Minimum Fuel Price Per Week with Store
min_fuel_price_df = features_data_df.groupBy("store", "date").agg(min("Fuel_Price").alias("min_fuel_price"))
min_fuel_price_per_week = min_fuel_price_df.orderBy(col("min_fuel_price").asc())

# Show result
min_fuel_price_per_week.show()

# 9. Yearly Store Performance Analysis (sorted by year)
yearly_performance_df = sales_data_df.groupBy("store", year("date").alias("year")).agg(sum("weekly_sales").alias("total_sales"))
yearly_performance_df = yearly_performance_df.orderBy("year", col("total_sales").desc())

# Show result
yearly_performance_df.show()

# 10. Weekly Performance Analysis with/without Offers
# Prepare features data with total_markdown
features_data_df = features_data_df.withColumn(
    "total_markdown",
    coalesce(col("MarkDown1").cast("double"), lit(0.0)) +
    coalesce(col("MarkDown2").cast("double"), lit(0.0)) +
    coalesce(col("MarkDown3").cast("double"), lit(0.0)) +
    coalesce(col("MarkDown4").cast("double"), lit(0.0)) +
    coalesce(col("MarkDown5").cast("double"), lit(0.0))
)

# Join sales data with features data
sales_with_features_df = sales_data_df.join(features_data_df, ["store", "date"], "inner")

# Filter and compute weekly sales for entries with offers (total_markdown > 0)
sales_with_offers_df = sales_with_features_df.filter(col("total_markdown") > 0)
weekly_sales_with_offers_df = sales_with_offers_df.groupBy("store", "date").agg(
    sum("weekly_sales").alias("total_sales_with_offers"),
    first("total_markdown").alias("total_markdown")  # Use first() to include total_markdown
).orderBy(col("total_sales_with_offers").desc())  # Order by sales high to low

# Filter and compute weekly sales for entries without offers (total_markdown = 0)
sales_without_offers_df = sales_with_features_df.filter(col("total_markdown") == 0)
weekly_sales_without_offers_df = sales_without_offers_df.groupBy("store", "date").agg(
    sum("weekly_sales").alias("total_sales_without_offers"),
    first("total_markdown").alias("total_markdown")  # Use first() to include total_markdown
).orderBy(col("total_sales_without_offers").desc())  # Order by sales high to low

# Show results
print("Weekly Sales with Offers (High to Low):")
weekly_sales_with_offers_df.show()

print("Weekly Sales without Offers (High to Low):")
weekly_sales_without_offers_df.show()

# Stop the Spark session
spark.stop()
