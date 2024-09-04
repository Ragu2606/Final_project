#!/bin/bash

# Variables
JMX_EXPORTER_VERSION="1.0.1"
PROMETHEUS_VERSION="2.54.1"
GRAFANA_VERSION="11.1.5"
MYSQL_EXPORTER_VERSION="0.15.0"

# Directories
EXPORTER_DIR="/opt/exporters"
PROMETHEUS_DIR="/opt/prometheus"
GRAFANA_DIR="/opt/grafana"
MYSQL_EXPORTER_DIR="/opt/mysql_exporter"
HADOOP_JAR_PATH="/lib/hadoop/hadoop-common.jar"
HIVE_JAR_PATH="/lib/hive/lib/hive-exec.jar"
SQOOP_JAR_PATH="/lib/sqoop/sqoop-1.4.7.jar"

# Create directories with sudo
sudo mkdir -p $EXPORTER_DIR
sudo mkdir -p $PROMETHEUS_DIR
sudo mkdir -p $GRAFANA_DIR
sudo mkdir -p $MYSQL_EXPORTER_DIR

# Download and setup JMX Exporter with sudo
echo "Downloading JMX Exporter..."
sudo wget -P $EXPORTER_DIR https://repo.maven.apache.org/maven2/io/prometheus/jmx/jmx_prometheus_javaagent/${JMX_EXPORTER_VERSION}/jmx_prometheus_javaagent-${JMX_EXPORTER_VERSION}.jar

# Create JMX Exporter configuration file with sudo
echo "Creating JMX Exporter configuration file..."
sudo tee $EXPORTER_DIR/jmx_exporter_config.yml > /dev/null <<EOL
rules:
  - pattern: '.*'
    name: 'jmx_exporter'
    type: GAUGE
EOL

# Setup Spark, Hadoop, Hive, and Sqoop configurations
echo "Configuring Spark, Hadoop, Hive, and Sqoop for JMX Exporter..."

SPARK_CONF_DIR="/etc/spark/conf"
HADOOP_CONF_DIR="/etc/hadoop/conf"
HIVE_CONF_DIR="/etc/hive/conf"
SQOOP_CONF_DIR="/etc/sqoop/conf"

# Spark configuration
sudo bash -c "echo 'export SPARK_JAVA_OPTS=\"\$SPARK_JAVA_OPTS -javaagent:$EXPORTER_DIR/jmx_prometheus_javaagent-${JMX_EXPORTER_VERSION}.jar=7071:$EXPORTER_DIR/jmx_exporter_config.yml\"' >> $SPARK_CONF_DIR/spark-env.sh"

# Hadoop configuration with JAR path
sudo bash -c "echo 'export HADOOP_OPTS=\"\$HADOOP_OPTS -javaagent:$EXPORTER_DIR/jmx_prometheus_javaagent-${JMX_EXPORTER_VERSION}.jar=7072:$EXPORTER_DIR/jmx_exporter_config.yml -Djava.class.path=$HADOOP_JAR_PATH\"' >> $HADOOP_CONF_DIR/hadoop-env.sh"

# Hive configuration with JAR path
sudo bash -c "echo 'export HIVE_OPTS=\"\$HIVE_OPTS -javaagent:$EXPORTER_DIR/jmx_prometheus_javaagent-${JMX_EXPORTER_VERSION}.jar=7073:$EXPORTER_DIR/jmx_exporter_config.yml -Djava.class.path=$HIVE_JAR_PATH\"' >> $HIVE_CONF_DIR/hive-env.sh"

# Sqoop configuration with JAR path
sudo bash -c "echo 'export SQOOP_OPTS=\"\$SQOOP_OPTS -javaagent:$EXPORTER_DIR/jmx_prometheus_javaagent-${JMX_EXPORTER_VERSION}.jar=7074:$EXPORTER_DIR/jmx_exporter_config.yml -Djava.class.path=$SQOOP_JAR_PATH\"' >> $SQOOP_CONF_DIR/sqoop-env.sh"

# Download and setup MySQL Exporter with sudo
echo "Downloading MySQL Exporter..."
sudo wget -P $MYSQL_EXPORTER_DIR https://github.com/prometheus/mysqld_exporter/releases/download/v${MYSQL_EXPORTER_VERSION}/mysqld_exporter-${MYSQL_EXPORTER_VERSION}.linux-amd64.tar.gz
sudo tar -xvf $MYSQL_EXPORTER_DIR/mysqld_exporter-${MYSQL_EXPORTER_VERSION}.linux-amd64.tar.gz -C $MYSQL_EXPORTER_DIR --strip-components=1

# Create MySQL Exporter configuration file with sudo
echo "Creating MySQL Exporter configuration file..."
sudo tee $MYSQL_EXPORTER_DIR/my.cnf > /dev/null <<EOL
[client]
user=prometheus
password=your_mysql_password
EOL

# Start MySQL Exporter with sudo
echo "Starting MySQL Exporter..."
sudo $MYSQL_EXPORTER_DIR/mysqld_exporter --config.my-cnf=$MYSQL_EXPORTER_DIR/my.cnf &

# Download and install Prometheus with sudo
echo "Downloading and installing Prometheus..."
sudo wget -P $PROMETHEUS_DI#!/bin/bash
f
# Variables
JMX_EXPORTER_VERSION="1.0.1"
PROMETHEUS_VERSION="2.54.1"
GRAFANA_VERSION="11.1.5"
MYSQL_EXPORTER_VERSION="0.15.0"

# Directories
EXPORTER_DIR="/opt/exporters"
PROMETHEUS_DIR="/opt/prometheus"
GRAFANA_DIR="/opt/grafana"
MYSQL_EXPORTER_DIR="/opt/mysql_exporter"
HADOOP_JAR_PATH="/lib/hadoop"
HIVE_JAR_PATH="/lib/hive/lib"
SQOOP_JAR_PATH="/lib/sqoop"

# Create directories with sudo
sudo mkdir -p $EXPORTER_DIR
sudo mkdir -p $PROMETHEUS_DIR
sudo mkdir -p $GRAFANA_DIR
sudo mkdir -p $MYSQL_EXPORTER_DIR

# Download and setup JMX Exporter with sudo
echo "Downloading JMX Exporter..."
sudo wget -P $EXPORTER_DIR https://repo.maven.apache.org/maven2/io/prometheus/jmx/jmx_prometheus_javaagent/${JMX_EXPORTER_VERSION}/jmx_prometheus_javaagent-${JMX_EXPORTER_VERSION}.jar

# Create JMX Exporter configuration file with sudo
echo "Creating JMX Exporter configuration file..."
sudo tee $EXPORTER_DIR/jmx_exporter_config.yml > /dev/null <<EOL
rules:
  - pattern: '.*'
    name: 'jmx_exporter'
    type: GAUGE
EOL

# Setup Spark, Hadoop, Hive, and Sqoop configurations
echo "Configuring Spark, Hadoop, Hive, and Sqoop for JMX Exporter..."

SPARK_CONF_DIR="/etc/spark/conf"
HADOOP_CONF_DIR="/etc/hadoop/conf"
HIVE_CONF_DIR="/etc/hive/conf"
SQOOP_CONF_DIR="/etc/sqoop/conf"

# Spark configuration
sudo bash -c "echo 'export SPARK_JAVA_OPTS=\"\$SPARK_JAVA_OPTS -javaagent:$EXPORTER_DIR/jmx_prometheus_javaagent-${JMX_EXPORTER_VERSION}.jar=7071:$EXPORTER_DIR/jmx_exporter_config.yml\"' >> $SPARK_CONF_DIR/spark-env.sh"

# Hadoop configuration with JAR path
sudo bash -c "echo 'export HADOOP_OPTS=\"\$HADOOP_OPTS -javaagent:$EXPORTER_DIR/jmx_prometheus_javaagent-${JMX_EXPORTER_VERSION}.jar=7072:$EXPORTER_DIR/jmx_exporter_config.yml -Djava.class.path=$HADOOP_JAR_PATH\"' >> $HADOOP_CONF_DIR/hadoop-env.sh"

# Hive configuration with JAR path
sudo bash -c "echo 'export HIVE_OPTS=\"\$HIVE_OPTS -javaagent:$EXPORTER_DIR/jmx_prometheus_javaagent-${JMX_EXPORTER_VERSION}.jar=7073:$EXPORTER_DIR/jmx_exporter_config.yml -Djava.class.path=$HIVE_JAR_PATH\"' >> $HIVE_CONF_DIR/hive-env.sh"

# Sqoop configuration with JAR path
sudo bash -c "echo 'export SQOOP_OPTS=\"\$SQOOP_OPTS -javaagent:$EXPORTER_DIR/jmx_prometheus_javaagent-${JMX_EXPORTER_VERSION}.jar=7074:$EXPORTER_DIR/jmx_exporter_config.yml -Djava.class.path=$SQOOP_JAR_PATH\"' >> $SQOOP_CONF_DIR/sqoop-env.sh"

# Download and setup MySQL Exporter with sudo
echo "Downloading MySQL Exporter..."
sudo wget -P $MYSQL_EXPORTER_DIR https://github.com/prometheus/mysqld_exporter/releases/download/v${MYSQL_EXPORTER_VERSION}/mysqld_exporter-${MYSQL_EXPORTER_VERSION}.linux-amd64.tar.gz
sudo tar -xvf $MYSQL_EXPORTER_DIR/mysqld_exporter-${MYSQL_EXPORTER_VERSION}.linux-amd64.tar.gz -C $MYSQL_EXPORTER_DIR --strip-components=1

# Create MySQL Exporter configuration file with sudo
echo "Creating MySQL Exporter configuration file..."
sudo tee $MYSQL_EXPORTER_DIR/my.cnf > /dev/null <<EOL
[client]
user=prometheus
password=your_mysql_password
EOL

# Start MySQL Exporter with sudo
echo "Starting MySQL Exporter..."
sudo $MYSQL_EXPORTER_DIR/mysqld_exporter --config.my-cnf=$MYSQL_EXPORTER_DIR/my.cnf &

# Download and install Prometheus with sudo
echo "Downloading and installing Prometheus..."
sudo wget -P $PROMETHEUS_DIR https://github.com/prometheus/prometheus/releases/download/v${PROMETHEUS_VERSION}/prometheus-${PROMETHEUS_VERSION}.linux-amd64.tar.gz
sudo tar -xvf $PROMETHEUS_DIR/prometheus-${PROMETHEUS_VERSION}.linux-amd64.tar.gz -C $PROMETHEUS_DIR --strip-components=1

# Create Prometheus configuration file with sudo
echo "Creating Prometheus configuration file..."
sudo tee $PROMETHEUS_DIR/prometheus.yml > /dev/null <<EOL
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'spark'
    static_configs:
      - targets: ['localhost:7071']

  - job_name: 'hadoop'
    static_configs:
      - targets: ['localhost:7072']

  - job_name: 'hive'
    static_configs:
      - targets: ['localhost:7073']

  - job_name: 'sqoop'
    static_configs:
      - targets: ['localhost:7074']

  - job_name: 'mysql'
    static_configs:
      - targets: ['database-1.c9486ksgkje3.ap-south-1.rds.amazonaws.com:3306']

  - job_name: 'jupyter'
    static_configs:
      - targets: ['localhost:<port>']

  - job_name: 'livy'
    static_configs:
      - targets: ['localhost:<port>']
EOL

# Start Prometheus with sudo
echo "Starting Prometheus..."
sudo $PROMETHEUS_DIR/prometheus --config.file=$PROMETHEUS_DIR/prometheus.yml &

# Download and install Grafana with sudo
echo "Downloading and installing Grafana..."
sudo wget -P $GRAFANA_DIR https://dl.grafana.com/enterprise/release/grafana-enterprise-${GRAFANA_VERSION}.linux-amd64.tar.gz
sudo tar -xvf $GRAFANA_DIR/grafana-enterprise-${GRAFANA_VERSION}.linux-amd64.tar.gz -C $GRAFANA_DIR --strip-components=1

# Start Grafana with sudo
echo "Starting Grafana..."
sudo $GRAFANA_DIR/bin/grafana-server &

# Output status
echo "Monitoring setup completed. Access Prometheus at http://localhost:9090 and Grafana at http://localhost:3000."
R https://github.com/prometheus/prometheus/releases/download/v${PROMETHEUS_VERSION}/prometheus-${PROMETHEUS_VERSION}.linux-amd64.tar.gz
sudo tar -xvf $PROMETHEUS_DIR/prometheus-${PROMETHEUS_VERSION}.linux-amd64.tar.gz -C $PROMETHEUS_DIR --strip-components=1

# Create Prometheus configuration file with sudo
echo "Creating Prometheus configuration file..."
sudo tee $PROMETHEUS_DIR/prometheus.yml > /dev/null <<EOL

