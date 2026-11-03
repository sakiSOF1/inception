*This project has been created as part of the 42 curriculum by sessaki.*

# Description

## Inception

Inception is a 42 system-administration project whose goal is to build a
small infrastructure using Docker and Docker Compose inside a virtual
machine.

The mandatory stack contains three isolated services:

-   **NGINX** --- the only public entry point; provides HTTPS on port
    443 and forwards PHP requests through FastCGI.
-   **WordPress + PHP-FPM** --- provides and executes the WordPress
    website.
-   **MariaDB** --- stores the WordPress database.

The services communicate through a dedicated Docker bridge network.
WordPress files and the MariaDB database use persistent named volumes
backed by `/home/sessaki/data/` on the host.

## Architecture

``` text
                    HTTPS :443
                         |
                         v
                  +-------------+
                  |    NGINX    |
                  |  TLS/SSL    |
                  +------+------+ 
                         |
                    FastCGI :9000
                         |
                         v
                  +-------------+
                  |  WordPress  |
                  |  PHP-FPM    |
                  +------+------+ 
                         |
                     MySQL :3306
                         |
                         v
                  +-------------+
                  |   MariaDB   |
                  +-------------+

          All services share a Docker network.
```

## Docker and main design choices

Docker isolates each service in its own container. Docker Compose
defines the services, network, volumes, builds, environment and port
mappings.

### Virtual Machines vs Docker

A VM virtualizes a complete operating system, including its kernel.
Docker containers share the host kernel while isolating applications and
their dependencies.

Docker is generally lighter and faster to start. In Inception, the
required VM provides the isolated environment in which the Docker
infrastructure runs.

### Secrets vs Environment Variables

Environment variables are appropriate for non-sensitive configuration
such as the domain name and database name.

Passwords and other confidential values must not be hard-coded in
Dockerfiles or committed to Git. This project keeps confidential values
outside the repository and uses the configured secret mechanism for
sensitive credentials.

### Docker Network vs Host Network

A Docker bridge network provides private communication between
containers. Services can communicate using Compose service names such as
`mariadb` and `wordpress`.

Host networking is not used because it removes Docker network isolation
and is forbidden by the project requirements.

### Docker Volumes vs Bind Mounts

Docker named volumes provide persistent storage managed by Docker. In
this project they are used for the WordPress files and MariaDB database,
with their host-backed data located under `/home/sessaki/data/`.

The persistent Compose storages are named volumes rather than direct
bind mounts.

## Instructions

### Prerequisites

The project is intended to run inside the required virtual machine with
Docker, Docker Compose and Make installed.

### Configuration

Create/configure:

``` text
srcs/.env
```

with the required non-secret values. Confidential values must remain
outside Git.

The project domain is:

``` text
https://42.sessaki.fr
```

The domain must resolve to the local machine/VM according to the project
setup.

### Build and start

From the repository root:

``` bash
make
```

Check the services:

``` bash
docker compose -f srcs/docker-compose.yml ps
```

### Stop

Use the project's stop target:

``` bash
make down
```

or Docker Compose directly:

``` bash
docker compose -f srcs/docker-compose.yml down
```

### Access

Website:

``` text
https://42.sessaki.fr
```

Administration:

``` text
https://42.sessaki.fr/wp-admin/
```

Only HTTPS port 443 is exposed by the mandatory stack.

## Resources

-   Docker: https://docs.docker.com/
-   Docker Compose: https://docs.docker.com/compose/
-   Docker volumes: https://docs.docker.com/engine/storage/volumes/
-   Docker networking: https://docs.docker.com/engine/network/
-   NGINX: https://nginx.org/en/docs/
-   PHP-FPM: https://www.php.net/manual/en/install.fpm.php
-   WordPress developer documentation: https://developer.wordpress.org/
-   MariaDB documentation: https://mariadb.com/docs/

### AI usage

AI was used as a learning and review assistant for understanding Docker,
Docker Compose, networks, volumes, NGINX, PHP-FPM, WordPress and
MariaDB; troubleshooting configuration/connectivity issues; reviewing
scripts and configuration; and preparing defense/revision material.

Generated suggestions were reviewed, adapted and tested against the
actual project.
