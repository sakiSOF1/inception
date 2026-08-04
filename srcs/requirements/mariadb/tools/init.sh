#!/bin/bash
set -e

mysqld_safe --bind-address=0.0.0.0 &

until mysql -u root -e "SELECT 1;" >/dev/null 2>&1
do
    sleep 1
done

mysql -u root << EOF
CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};

CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';

GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';

FLUSH PRIVILEGES;
EOF

wait
