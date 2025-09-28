#!/bin/bash
set -e

# Initialize MariaDB data directory if it doesn't exist
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Initializing MariaDB data directory..."
    mysql_install_db --user=mysql --datadir=/var/lib/mysql
    
    echo "Starting MariaDB for initial setup..."
    mysqld_safe --user=mysql --datadir=/var/lib/mysql &
    
    # Wait for MariaDB to start
    for i in {1..30}; do
        if mysql -u root -e "SELECT 1" > /dev/null 2>&1; then
            break
        fi
        echo "Waiting for MariaDB to start... ($i/30)"
        sleep 1
    done
    
    echo "Setting up MariaDB database and users..."
    mysql -u root << EOF
-- Set root password
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
DELETE FROM mysql.user WHERE User='';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';

-- Create WordPress database and user
CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
EOF
    
    echo "Stopping initial MariaDB instance..."
    mysqladmin -u root -p${MYSQL_ROOT_PASSWORD} shutdown
    
    echo "MariaDB initialization complete."
fi

echo "Starting MariaDB server..."
exec mysqld_safe --user=mysql --datadir=/var/lib/mysql