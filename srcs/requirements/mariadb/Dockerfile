FROM debian:bookworm-slim

ARG DEBIAN_FRONTEND=noninteractive
ENV DEBIAN_FRONTEND=$DEBIAN_FRONTEND

# Install MariaDB server and necessary packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    mariadb-server \
    mariadb-client \
    && rm -rf /var/lib/apt/lists/*

# Create directories for MariaDB
RUN mkdir -p /var/run/mysqld /var/lib/mysql \
    && chown -R mysql:mysql /var/run/mysqld /var/lib/mysql

# Copy initialization script
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Configure MariaDB to bind to all addresses
RUN sed -i 's/bind-address\s*=\s*127.0.0.1/bind-address = 0.0.0.0/' /etc/mysql/mariadb.conf.d/50-server.cnf

# Expose port 3306 for MariaDB
EXPOSE 3306

# Use custom entrypoint script
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
