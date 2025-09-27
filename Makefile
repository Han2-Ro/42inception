DOCKER_CMD = docker
COMPOSE_CMD = docker compose
COMPOSE_FILE = srcs/docker-compose.yml

.PHONY: all build up down clean re

all: build up

build:
	$(COMPOSE_CMD) -f $(COMPOSE_FILE) build

up:
	$(COMPOSE_CMD) -f $(COMPOSE_FILE) up -d

down:
	$(COMPOSE_CMD) -f $(COMPOSE_FILE) down

clean: down
	$(DOCKER_CMD) system prune -af

re: clean all
