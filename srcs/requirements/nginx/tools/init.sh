#!/bin/bash
set -e

openssl req -x509 -nodes -days 365 \
    -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/server.key \
    -out /etc/nginx/ssl/server.crt \
    -subj "/C=MA/ST=Morocco/L=BenGuerir/O=42/OU=Student/CN=${DOMAIN_NAME}"

exec nginx -g "daemon off;"