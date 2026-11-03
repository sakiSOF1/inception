#!/bin/bash

set -e

cd /var/www/html

if [ ! -f index.php ]; then
    wp core download --allow-root
fi

if [ ! -f /var/www/html/wp-config.php ]; then
    wp config create \
        --dbname="$MYSQL_DATABASE" \
        --dbuser="$MYSQL_USER" \
        --dbpass="$MYSQL_PASSWORD" \
        --dbhost="mariadb" \
        --allow-root
fi

until wp db check --allow-root >/dev/null 2>&1
do
    echo "Waiting for MariaDB..."
    sleep 2
done

if ! wp core is-installed --allow-root; then
    wp core install \
        --url="$DOMAIN_NAME" \
        --title="$WP_TITLE" \
        --admin_user="$WP_ADMIN_USER" \
        --admin_password="$WP_ADMIN_PASSWORD" \
        --admin_email="$WP_ADMIN_EMAIL" \
        --allow-root

    wp user create \
        "$WP_USER" \
        "$WP_USER_EMAIL" \
        --user_pass="$WP_USER_PASSWORD" \
        --allow-root
fi

mkdir -p /run/php

exec php-fpm8.2 -F