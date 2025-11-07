#!/bin/sh
set -e

WORDPRESS_PATH="/var/www/html"

# Check if WordPress is already installed
if [ ! -f "$WORDPRESS_PATH/wp-config.php" ]; then
    echo "WordPress not found in $WORDPRESS_PATH. Installing..."
    tmpdir=$(mktemp -d)
    curl -o "$tmpdir/wordpress.tar.gz" -fSL https://wordpress.org/latest.tar.gz
    tar -xzf "$tmpdir/wordpress.tar.gz" -C "$tmpdir"
    rm -rf "$WORDPRESS_PATH"/*
    cp -a "$tmpdir/wordpress/." "$WORDPRESS_PATH/"
    rm -rf "$tmpdir"
    chown -R www-data:www-data "$WORDPRESS_PATH"
    chmod -R 755 "$WORDPRESS_PATH"
    
    # Create wp-config.php with database settings
    echo "Creating wp-config.php..."
    cat > "$WORDPRESS_PATH/wp-config.php" << EOF
<?php
// WordPress Database Configuration
define('DB_NAME', '${MYSQL_DATABASE}');
define('DB_USER', '${MYSQL_USER}');
define('DB_PASSWORD', '${MYSQL_PASSWORD}');
define('DB_HOST', 'mariadb:3306');
define('DB_CHARSET', 'utf8');
define('DB_COLLATE', '');

// WordPress Authentication Unique Keys and Salts
define('AUTH_KEY',         'your-auth-key-here');
define('SECURE_AUTH_KEY',  'your-secure-auth-key-here');
define('LOGGED_IN_KEY',    'your-logged-in-key-here');
define('NONCE_KEY',        'your-nonce-key-here');
define('AUTH_SALT',        'your-auth-salt-here');
define('SECURE_AUTH_SALT', 'your-secure-auth-salt-here');
define('LOGGED_IN_SALT',   'your-logged-in-salt-here');
define('NONCE_SALT',       'your-nonce-salt-here');

// WordPress Database Table prefix
\$table_prefix  = 'wp_';

// WordPress Debugging
define('WP_DEBUG', false);

// Absolute path to the WordPress directory
if ( !defined('ABSPATH') )
    define('ABSPATH', dirname(__FILE__) . '/');

// Sets up WordPress vars and included files
require_once(ABSPATH . 'wp-settings.php');
EOF
    
    chown www-data:www-data "$WORDPRESS_PATH/wp-config.php"
    echo "WordPress installed and configured."
else
    echo "WordPress already present in $WORDPRESS_PATH. Skipping download."
fi

exec php-fpm8.2 -F
