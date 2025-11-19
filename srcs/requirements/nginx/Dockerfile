FROM debian:bookworm

RUN apt-get update && apt-get install -y --no-install-recommends nginx openssl && \
    rm -rf /var/lib/apt/lists/*

# Create directories and SSL certificate
RUN mkdir -p /var/log/nginx /var/cache/nginx && \
    mkdir -p /etc/ssl/certs /etc/ssl/private && \
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout /etc/ssl/private/ssl-cert-snakeoil.key \
        -out /etc/ssl/certs/ssl-cert-snakeoil.pem \
        -subj "/C=AT/ST=Vienna/L=Vienna/O=42Vienna/CN=hrother.42.fr" \
        -addext "subjectAltName=DNS:localhost,DNS:*.localhost,DNS:hrother.42.fr,IP:127.0.0.1"

COPY conf/nginx.conf /etc/nginx/nginx.conf

RUN touch var/www/html/index.php

EXPOSE 443

# Run nginx in foreground
ENTRYPOINT ["nginx", "-g", "daemon off;"]