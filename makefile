# Set default no argument goal to help
.DEFAULT_GOAL := help

# Ensure that errors don't hide inside pipes
SHELL         = /bin/bash
.SHELLFLAGS   = -o pipefail -c

# For cleanup, get Compose project name from .env file
APP_PROJECT?=$(shell cat .env | grep COMPOSE_PROJECT_NAME | sed 's/^*=//')
APPS_NETWORK?=$(shell cat .env | grep APPS_NETWORK | sed 's/^*=//')

# Every command is a PHONY, to avoid file naming confliction.
.PHONY: help
help:
	@echo "=============================================================================="
	@echo "                  Headless Wordpress docker composition "
	@echo "      https://github.com/elasticlabs/headless-wordpress-docker-compose "
	@echo " "
	@echo "Hints for developers:"
	@echo "  make build         # Makes container & volumes cleanup, and builds the stack"
	@echo "  make up            # With working proxy, brings up the testing infrastructure"
	@echo "  make update        # Update the whole stack"
	@echo "  make hard-cleanup  # Hard cleanup of images, containers, networks, volumes & data"
	@echo "==================================================================================="

.PHONY: up
up:
	git stash && git pull
	docker-compose -f docker-compose.yml up -d --build --remove-orphans

.PHONY: build
build:
	# Network creation if not done yet
	@echo "[INFO] Create ${APPS_NETWORK} docker network if it doesn't already exists"
	docker network inspect docker create ${APPS_NETWORK} >/dev/null 2>&1 \
		|| docker network create --driver bridge my_local_network
	# Build the stack
	@echo "[INFO]Building the application"
	docker-compose -f docker-compose.yml --build

.PHONY: update
update: 
	docker-compose -f docker-compose.yml pull 
	docker-compose -f docker-compose.yml up -d --build 	

.PHONY: hard-cleanup
hard-cleanup:
	@echo "[INFO] Bringing done the Headless Wordpress Stack"
	docker-compose -f docker-compose.yml down --remove-orphans
	# 2nd : clean up all containers & images, without deleting static volumes
	@echo "[INFO] Cleaning up containers & images"
	docker rm $(docker ps -a -q)
	docker rmi $(docker images -q)
	# Remove all dangling docker volumes
	@echo "[INFO] Remove all dangling docker volumes"
	docker volume rm $(shell docker volume ls -qf dangling=true)
	# Docker system cleanup
	docker system prune -a
	# Delete all hosted persistent data available in local directorys
	@echo "[INFO] Remove all stored logs and data in local volumes!"
	rm -rf app_logs/*
	rm -rf app_mariadb/*
	rm -rf app_wordpress/*

.PHONY: wait
wait: 
	sleep 5