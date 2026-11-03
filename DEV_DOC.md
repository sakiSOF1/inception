# Developer Documentation

## Project structure

``` text
.
├── Makefile
├── secrets/
└── srcs/
    ├── .env
    ├── docker-compose.yml
    └── requirements/
        ├── mariadb/
        ├── nginx/
        └── wordpress/
```

Each mandatory service has its own Dockerfile and startup configuration.

## Prerequisites

Inside the required VM, verify:

``` bash
docker --version
docker compose version
make --version
git --version
```

## Configuration

Non-secret configuration belongs in:

``` text
srcs/.env
```

Typical values include the domain, database name/user and WordPress
configuration.

Confidential values such as database passwords and the WordPress
administrator password must not be hard-coded in Dockerfiles or
committed to Git. Keep them in the project's local secret configuration.

## Build and launch

From the repository root:

``` bash
make
```

You can also inspect the Compose configuration:

``` bash
docker compose -f srcs/docker-compose.yml config
```

Build explicitly:

``` bash
docker compose -f srcs/docker-compose.yml build
```

Launch explicitly:

``` bash
docker compose -f srcs/docker-compose.yml up -d
```

## Container management

``` bash
docker compose -f srcs/docker-compose.yml ps
docker compose -f srcs/docker-compose.yml logs
docker compose -f srcs/docker-compose.yml logs -f wordpress
```

Open a shell:

``` bash
docker compose -f srcs/docker-compose.yml exec wordpress bash
docker compose -f srcs/docker-compose.yml exec mariadb bash
docker compose -f srcs/docker-compose.yml exec nginx bash
```

## Network

The services share a dedicated Docker bridge network.

Internal communication is:

``` text
NGINX
  |
  | FastCGI
  v
wordpress:9000

WordPress
  |
  | MySQL
  v
mariadb:3306
```

Docker Compose provides internal DNS using service names. Therefore
WordPress can use `mariadb` as the database host instead of a container
IP.

## NGINX

NGINX is the only public entry point.

``` text
host:443 -> nginx:443
```

NGINX terminates TLS, serves web content and forwards PHP requests
through FastCGI to:

``` text
wordpress:9000
```

NGINX does not contain PHP-FPM or MariaDB.

## WordPress and PHP-FPM

The WordPress container contains WordPress, PHP, PHP-FPM, WP-CLI and the
MariaDB client.

The initialization script:

1.  enters `/var/www/html`;
2.  downloads WordPress if necessary;
3.  creates `wp-config.php` when needed;
4.  waits for database availability;
5.  installs WordPress when it is not already installed;
6.  creates the normal WordPress user;
7.  starts PHP-FPM in the foreground.

The WordPress directory is persistent through its named volume.

## MariaDB

MariaDB runs in its own container and stores its database in the MariaDB
named volume.

Its initialization is responsible for preparing the database directory,
starting MariaDB, creating the WordPress database/user and granting the
required privileges.

Check the database from WordPress with:

``` bash
docker compose -f srcs/docker-compose.yml exec wordpress     wp db check --allow-root
```

## Volumes and persistence

List volumes:

``` bash
docker volume ls
```

Inspect one:

``` bash
docker volume inspect <volume_name>
```

Persistent host data is stored under:

``` text
/home/sessaki/data/wordpress
/home/sessaki/data/mariadb
```

Do not remove these data locations during a normal stop/start operation.

## Rebuild

When Dockerfiles or build configuration changes:

``` bash
docker compose -f srcs/docker-compose.yml up -d --build
```

Be careful with volume removal because it destroys persistent project
state.

## Clean evaluation

The correction procedure starts from a clean Docker state. After
deliberately removing containers, images, volumes and networks, run:

``` bash
make
```

Then verify:

``` bash
docker compose -f srcs/docker-compose.yml ps
```

and access:

``` text
https://42.sessaki.fr
```

HTTP port 80 must not be exposed.

## Persistence test

1.  Start the stack.
2.  Modify the WordPress website.
3.  Verify the modification.
4.  Reboot the virtual machine.
5.  Start the stack again.
6.  Verify WordPress and MariaDB are still configured.
7.  Verify the WordPress modification is still present.

## Troubleshooting

### WordPress waits for MariaDB

``` bash
docker compose -f srcs/docker-compose.yml logs mariadb
docker compose -f srcs/docker-compose.yml logs wordpress
```

Test database connectivity from WordPress:

``` bash
docker compose -f srcs/docker-compose.yml exec wordpress     mysql -h mariadb -u "$MYSQL_USER" -p "$MYSQL_DATABASE"
```

Check the WordPress database:

``` bash
docker compose -f srcs/docker-compose.yml exec wordpress     wp db check --allow-root
```

### NGINX returns 502

Check PHP-FPM:

``` bash
docker compose -f srcs/docker-compose.yml exec wordpress pgrep -a php-fpm
```

Check its listening configuration:

``` bash
docker compose -f srcs/docker-compose.yml exec wordpress     grep -R "^listen" /etc/php/*/fpm/pool.d/
```

The PHP-FPM listening address/port must match NGINX's `fastcgi_pass`.

### NGINX TLS problem

``` bash
docker compose -f srcs/docker-compose.yml logs nginx
docker compose -f srcs/docker-compose.yml exec nginx nginx -T
```

Verify that the certificate and private key belong together.

## Defense topics

A developer should understand:

-   image vs container;
-   Docker vs VM;
-   Docker Compose;
-   bridge networks and service-name DNS;
-   published vs internal ports;
-   NGINX and reverse proxy behavior;
-   TLS;
-   FastCGI;
-   PHP-FPM;
-   WordPress;
-   MariaDB;
-   named volumes and persistence;
-   environment variables vs secrets;
-   PID 1 and foreground processes;
-   why infinite-loop/background-daemon entrypoint hacks are prohibited.
