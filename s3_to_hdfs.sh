#!/bin/bash

# Define variables
S3_BUCKET='s3://dmartsales/features_data/Features_data_set.csv'
LOCAL_FILE='/tmp/Features_data_set.csv'
HDFS_DIR='/user/hadoop/features_data'
HDFS_FILE='/user/hadoop/features_data/Features_data_set.csv'

# Download the file from S3 to local filesystem
aws s3 cp $S3_BUCKET $LOCAL_FILE

# Create the HDFS directory if it does not exist
sudo -u hadoop hdfs dfs -mkdir -p $HDFS_DIR

# Move the file from local filesystem to HDFS
sudo -u hadoop hdfs dfs -put $LOCAL_FILE $HDFS_FILE

# Verify the file exists in HDFS
echo "Listing files in HDFS directory $HDFS_DIR:"
sudo -u hadoop hdfs dfs -ls $HDFS_DIR
