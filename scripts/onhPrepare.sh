#!/bin/bash

# Go to home directory
cd

# Branch name to install
BRANCH=$1

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

if [ "$?" -ne "0" ]
then
	echo "Clone project failed - check logs"
	exit 1
fi

cd openNetworkHMI

# Check branch flag
if [ -z "$BRANCH" ]
then
	echo "Installing default master branch"
else
	echo "Checkout openNetworkHMI to $BRANCH"
	git checkout $BRANCH
	if [ "$?" -ne "0" ]
	then
		echo "openNetworkHMI checkout to $BRANCH failed - see logs"
		exit 1
	fi
fi

# Install onh
sh install.sh

if [ "$?" -ne "0" ]
then
	echo "Installation failed - check logs"
	exit 1
fi

echo "Prepare www"

# Deactivate default apache site
sudo a2dissite -q 000-default.conf
sudo systemctl reload apache2

# Update permissions
sudo chown -R :www-data /home/onh/openNetworkHMI/openNetworkHMI_web/var/
sudo chmod -R g+w /home/onh/openNetworkHMI/openNetworkHMI_web/var/
