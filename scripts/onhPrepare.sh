#!/bin/bash

# Go to home directory
cd

# Wait on database
DB_STARTED="inactive"
while [ "$DB_STARTED" != "active" ]
do
	sleep 1
	DB_STARTED=$(sudo systemctl is-active mariadb.service)
done

echo "Prepare DB access"

# Prepare DB
sudo mysql --user=root <<_EOF_
	UPDATE mysql.user SET Password=PASSWORD('root') WHERE User='root';
	DELETE FROM mysql.user WHERE User='';
	DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
	DROP DATABASE IF EXISTS test;
	DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
	CREATE USER 'admin'@'localhost' IDENTIFIED BY 'admin';
	GRANT ALL PRIVILEGES ON * . * TO 'admin'@'localhost';
	FLUSH PRIVILEGES;
_EOF_

# Clone onh repo
git clone --recursive https://github.com/matmir/openNetworkHMI.git

# Install onh
cd openNetworkHMI
sh install.sh

echo "Prepare www"

# Deactivate default apache site
sudo a2dissite -q 000-default.conf
sudo systemctl reload apache2

# Update permissions
sudo chown -R :www-data /home/onh/openNetworkHMI/openNetworkHMI_web/var/
sudo chmod -R g+w /home/onh/openNetworkHMI/openNetworkHMI_web/var/
