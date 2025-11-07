#!/bin/sh
set -e

WORDPRESS_PATH="/var/www/html"

# Function to wait for database
wait_for_db() {
    echo "Waiting for database connection..."
    until php -r "
        \$mysqli = new mysqli('mariadb', '${MYSQL_USER}', '${MYSQL_PASSWORD}', '${MYSQL_DATABASE}');
        if (\$mysqli->connect_error) {
            exit(1);
        }
        echo 'Database connected successfully';
        \$mysqli->close();
    " 2>/dev/null; do
        echo "Database not ready, waiting..."
        sleep 2
    done
    echo "Database is ready!"
}

# Check if WordPress is already installed
if [ ! -f "$WORDPRESS_PATH/wp-config.php" ]; then
    echo "WordPress not found in $WORDPRESS_PATH. Installing..."
    
    # Wait for database to be ready
    wait_for_db
    
    # Download WordPress using WP-CLI
    cd "$WORDPRESS_PATH"
    wp core download --allow-root
    
    # Create wp-config.php
    wp config create \
        --dbname="$MYSQL_DATABASE" \
        --dbuser="$MYSQL_USER" \
        --dbpass="$MYSQL_PASSWORD" \
        --dbhost="mariadb:3306" \
        --allow-root
    
    # Install WordPress with admin user
    wp core install \
        --url="$WP_URL" \
        --title="$WP_TITLE" \
        --admin_user="$WP_ADMIN_USER" \
        --admin_password="$WP_ADMIN_PASSWORD" \
        --admin_email="$WP_ADMIN_EMAIL" \
        --allow-root
    
    # Create additional user (as required by subject)
    wp user create "$WP_USER" "$WP_USER_EMAIL" \
        --user_pass="$WP_USER_PASSWORD" \
        --role=editor \
        --allow-root
    
    # Set proper ownership
    chown -R www-data:www-data "$WORDPRESS_PATH"
    chmod -R 755 "$WORDPRESS_PATH"
    
    echo "WordPress installed and configured with admin user."
else
    echo "WordPress already present in $WORDPRESS_PATH. Skipping installation."
fi

exec php-fpm8.2 -F
