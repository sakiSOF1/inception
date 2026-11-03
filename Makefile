NAME = inception
COMPOSE = docker compose -f srcs/docker-compose.yml

all: build up

build:
	$(COMPOSE) build

up:
	$(COMPOSE) up -d

down:
	$(COMPOSE) down

clean: down

fclean: down
	docker volume rm srcs_mariadb_data srcs_wordpress_data 2>/dev/null || true
	docker image rm mariadb wordpress nginx 2>/dev/null || true
	sudo rm -rf /home/$(LOGNAME)/data/mariadb/*
	sudo rm -rf /home/$(LOGNAME)/data/wordpress/*
	docker system prune -af

re: fclean all

.PHONY: all build up down clean fclean re