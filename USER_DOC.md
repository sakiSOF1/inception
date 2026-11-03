# User Documentation

## Services

The stack provides:

  Service               Purpose
  --------------------- ---------------------------------------
  NGINX                 HTTPS entry point and web server
  WordPress + PHP-FPM   Website application and PHP execution
  MariaDB               WordPress database

Only NGINX is exposed publicly through port 443.

## Start the project

From the repository root:

``` bash
make
```

Check the services:

``` bash
docker compose -f srcs/docker-compose.yml ps
```

The three mandatory services should be running:

``` text
nginx
wordpress
mariadb
```

## Stop the project

To stop the stack while preserving persistent data:

``` bash
make down
```

or:

``` bash
docker compose -f srcs/docker-compose.yml down
```

Do not remove the persistent volumes/data unless a complete reset is
intended.

## Access WordPress

Open:

``` text
https://42.sessaki.fr
```

A certificate warning may appear because the project can use a
self-signed certificate.

Administration panel:

``` text
https://42.sessaki.fr/wp-admin/
```

Use the administrator credentials configured for the project.

## Credentials

Non-secret configuration is stored in:

``` text
srcs/.env
```

Confidential credentials are kept in the local secret
files/configuration used by the project.

Do not commit passwords, API keys or other confidential values to Git.

The WordPress administrator username must not contain `admin`, `Admin`,
`administrator` or `Administrator`.

## Check that services are running

``` bash
docker compose -f srcs/docker-compose.yml ps
```

View logs:

``` bash
docker compose -f srcs/docker-compose.yml logs nginx
docker compose -f srcs/docker-compose.yml logs wordpress
docker compose -f srcs/docker-compose.yml logs mariadb
```

Check the Docker network:

``` bash
docker network ls
```

Check persistent volumes:

``` bash
docker volume ls
docker volume inspect <volume_name>
```

The volume configuration should contain data under:

``` text
/home/sessaki/data/
```

## Persistence

Important persistent data is stored under:

``` text
/home/sessaki/data/wordpress
/home/sessaki/data/mariadb
```

The WordPress volume contains website files. The MariaDB volume contains
the database.

Recreating containers does not normally remove this persistent data.

After a VM reboot, start the stack again and verify that the website,
database and previous WordPress changes are still present.

## Basic troubleshooting

If a service is not running:

``` bash
docker compose -f srcs/docker-compose.yml ps
```

Then inspect its logs:

``` bash
docker compose -f srcs/docker-compose.yml logs <service>
```

If WordPress cannot reach MariaDB, verify that MariaDB is running and
that both services are connected to the same Docker network.

If NGINX returns `502 Bad Gateway`, verify that PHP-FPM is running in
the WordPress container and that its listening address/port matches
NGINX's FastCGI configuration.
