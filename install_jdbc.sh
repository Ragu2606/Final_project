sudo yum update -y
sudo yum install -y wget
wget -O mysql-connector-j-9.0.0.tar.gz https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-j-9.0.0.tar.gz
tar -xzf mysql-connector-j-9.0.0.tar.gz
sudo cp mysql-connector-j-9.0.0/mysql-connector-j-9.0.0.jar /usr/lib/sqoop/lib/
rm -rf mysql-connector-j-9.0.0.tar.gz mysql-connector-j-9.0.0

