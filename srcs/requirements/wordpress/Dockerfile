FROM debian:bookworm-slim

ARG DEBIAN_FRONTEND=noninteractive
ENV DEBIAN_FRONTEND=$DEBIAN_FRONTEND

# Update package index and install PHP and required extensions for WordPress
RUN apt-get update && apt-get install -y --no-install-recommends \
    php8.2 \
    php8.2-fpm \
    php8.2-mysql \
    php8.2-mysqli \
    php8.2-curl \
    php8.2-dom \
    php8.2-exif \
    php8.2-fileinfo \
    php8.2-mbstring \
    php8.2-xml \
    php8.2-zip \
    php8.2-gd \
    php8.2-iconv \
    curl \
    wget \
    tar \
    ca-certificates \
    && update-ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Create directories for WordPress
RUN mkdir -p /var/www/html /run/php

# Install WP-CLI
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

# Copy entrypoint script
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Configure PHP-FPM
RUN sed -i 's/listen = \/run\/php\/php8.2-fpm.sock/listen = 9000/' /etc/php/8.2/fpm/pool.d/www.conf && \
    sed -i 's/;listen.owner = www-data/listen.owner = www-data/' /etc/php/8.2/fpm/pool.d/www.conf && \
    sed -i 's/;listen.group = www-data/listen.group = www-data/' /etc/php/8.2/fpm/pool.d/www.conf

# Expose port 9000 for PHP-FPM
EXPOSE 9000

# Use custom entrypoint script
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
