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
    echo "WordPress installed."
else
    echo "WordPress already present in $WORDPRESS_PATH. Skipping download."
fi

exec php-fpm8.2 -F
