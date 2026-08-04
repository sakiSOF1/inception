#!/bin/bash

set -e

curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar

chmod +x wp-cli.phar

mv wp-cli.phar /usr/local/bin/wp

cd /var/www/html

wp core download --allow-root

wp config create \
    --dbname=$MYSQL_DATABASE \
    --dbuser=$MYSQL_USER \
    --dbpass=$MYSQL_PASSWORD \
    --dbhost=mariadb \
    --allow-root