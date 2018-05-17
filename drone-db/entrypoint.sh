#!/bin/sh

# Check to exist data of mysql.
if [ -n "$(ls /var/lib/mysql/)" ]; then
  echo 'Data already exists, skip initializing.'
else
  echo 'Data is empty, start initializing.'

  # Initialize mysql.
  mysql_install_db

  # Execute query to initialize.
  cat << EOF | /usr/bin/mysqld --bootstrap
# Imitate /usr/bin/mysql_secure_installation to set root password and delete unsafe user & database.
UPDATE mysql.user SET Password=PASSWORD('${MYSQL_ROOT_PASSWORD}') WHERE User='root';
DELETE FROM mysql.user WHERE User='';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
FLUSH PRIVILEGES;
# Create database & remote user use it.
CREATE DATABASE ${MYSQL_DATABASE};
GRANT ALL ON ${MYSQL_DATABASE}.* to '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
EOF
fi

# Create mysqld.sock directory.
mkdir -p /run/mysqld

# Run mysqld.
exec /usr/bin/mysqld --user=root --console
