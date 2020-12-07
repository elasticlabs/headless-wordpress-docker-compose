# Set default no argument goal to help
.DEFAULT_GOAL := help

# Ensure that errors don't hide inside pipes
SHELL         = /bin/bash
.SHELLFLAGS   = -o pipefail -c

# For cleanup, get Compose project name from .env file
DC_PROJECT?=$(shell cat .env | sed 's/^*=//')

# Every command is a PHONY, to avoid file naming confliction.
.PHONY: help
help:
	@echo "=============================================================================="
	@echo "                  Headless Wordpress docker composition "
	@echo "      https://github.com/elasticlabs/headless-wordpress-docker-compose "
	@echo " "
	@echo "Hints for developers:"
	@echo "  make build         # Makes container & volumes cleanup, and builds TEAMEngine"
	@echo "  make up            # With working proxy, brings up the testing infrastructure"
	@echo "  make update        # Update the whole stack"
	@echo "  make cleanup       # Cleanup of images, containers"
	@echo "  make hard-cleanup  # /!\ Hard cleanup of images, containers, networks, volumes & data""
	@echo "=============================================================================="

.PHONY: up
up:
    git stash && git pull
	docker-compose -f docker-compose.yml up -d --build --remove-orphans

.PHONY: build
build:
	docker-compose -f docker-compose.yml --build
 
.PHONY: update
update: 
	docker-compose -f docker-compose.yml pull 
	docker-compose -f docker-compose.yml up -d --build 	

.PHONY: hard-cleanup
hard-cleanup
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
    # Delete all hosted persistent data available in volumes
	@echo "[INFO] Cleaning up static volumes"
    docker volume rm -f $(DC_PROJECT)wp-base

.PHONY: wait
wait: 
	sleep 5