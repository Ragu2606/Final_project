#!/bin/bash

# Sqoop import for sales_data table
sqoop import \
  --connect jdbc:mysql://database-1.c9486ksgkje3.ap-south-1.rds.amazonaws.com:3306/dmart \
  --username admin \
  --password Dhuruv21 \
  --table sales_data \
  --hive-import \
  --hive-database dmart \
  --hive-table sales_data \
  --create-hive-table \
  --target-dir /user/hive/warehouse/dmart.db/sales_data \
  --m 1

# Sqoop import for stores_data table
sqoop import \
  --connect jdbc:mysql://database-1.c9486ksgkje3.ap-south-1.rds.amazonaws.com:3306/dmart \
  --username admin \
  --password Dhuruv21 \
  --table store_data \
  --hive-import \
  --hive-database dmart \
  --hive-table store_data \
  --create-hive-table \
  --target-dir /user/hive/warehouse/dmart.db/store_data \
  --m 1

