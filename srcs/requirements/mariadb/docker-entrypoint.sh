#!/bin/bash
set -eo pipefail

echo "Starting MariaDB entrypoint..."
MYSQL_PASSWORD=$(cat $MYSQL_PASSWORD_FILE)
MYSQL_ROOT_PASSWORD=$(cat $MYSQL_ROOT_PASSWORD_FILE)

# Initialize MariaDB if needed
if [ ! -f "/var/lib/mysql/.initialized" ]; then
    echo "Initializing MariaDB..."
    mysql_install_db --user=mysql --datadir=/var/lib/mysql --skip-name-resolve --skip-test-db
    
    # Start MariaDB in background for setup
    mysqld --user=mysql --datadir=/var/lib/mysql --skip-networking &
    PID="$!"
    
    # Wait for MariaDB to be ready
    for i in {1..30}; do
        if echo 'SELECT 1' | mysql --protocol=socket -uroot > /dev/null 2>&1; then
            break
        fi
        echo "Waiting for MariaDB to start... $i/30"
        sleep 1
    done
    
    # Setup database and user
    mysql --protocol=socket -uroot << EOSQL
-- Setup database and user
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';

-- Set root password (MariaDB 10.4+ syntax)
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
DELETE FROM mysql.user WHERE User='';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
FLUSH PRIVILEGES;
EOSQL
    
    # Stop MariaDB
    if ! kill -s TERM "$PID" || ! wait "$PID"; then
        echo "MariaDB initialization process failed."
        exit 1
    fi
    
    # Mark as initialized
    touch /var/lib/mysql/.initialized
    echo "MariaDB initialization complete."
fi

echo "Starting MariaDB server..."
exec mysqld --user=mysql