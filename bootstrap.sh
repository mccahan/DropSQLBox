#!/usr/bin/env bash

sudo apt-get update

# Set the default root password to 'root'
# DO NOT CONNECT THIS MACHINE TO THE INTERNET. YOU KNOW BETTER.
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password root'
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password root'

# Install the MySQL server and listen on all IPs
sudo apt-get install -y mysql-server
sudo sed -i.bak s/bind-address/#bind-address/g /etc/mysql/my.cnf
sudo sed -i -e 's/127.0.0.1/0.0.0.0/g' /etc/mysql/mysql.conf.d/mysqld.cnf
sudo service mysql restart

# Allow remote root access
mysql -u root -proot mysql -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY 'root' WITH GRANT OPTION;"

sudo service mysql stop
sudo mkdir /etc/systemd/system/mysql.service.d
cat << EOF | sudo tee /etc/systemd/system/mysql.service.d/start-stop.conf
[Service]
ExecStartPost=/vagrant/import.sh
ExecStopPre=/vagrant/export.sh
EOF
sudo systemctl daemon-reload

# Add the import/export scripts
cat << EOF | sudo tee /etc/init/mysql-up.conf
description "Run import after MySQL has started"
author "Ryan McCahan"

start on started mysql
task
exec /vagrant/import.sh
EOF

sudo service mysql restart

# Install the export script after our last restart so we don't dump some useless databases
cat << EOF | sudo tee /etc/init/mysql-down.conf
description "Run export just before MySQL shuts down"
author "Ryan McCahan"

start on stopping mysql
task
exec /vagrant/export.sh
EOF

# Create .my.cnf file for convenience/laziness
/usr/bin/printf "[client]\nuser=root\npassword=root" > /home/vagrant/.my.cnf

echo "Provisioning complete"
