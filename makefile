# Set default no argument goal to help
.DEFAULT_GOAL := help

# Ensure that errors don't hide inside pipes
SHELL         = /bin/bash
.SHELLFLAGS   = -o pipefail -c

# For cleanup, get Compose project name from .env file
APP_PROJECT?=$(shell cat .env | grep COMPOSE_PROJECT_NAME | sed 's/.*=//')
APP_BASEURL?=$(shell cat .env | grep VIRTUAL_HOST | sed 's/.*=//')
SOFTWARE_STACK = proxy wordpress mariadb adminer
WP_STACK = wordpress mariadb healthcheck toolbox

# Every command is a PHONY, to avoid file naming confliction.
.PHONY: help
help:
	@echo "====================================================================================="
	@echo "                   Headless Wordpress docker composition "
	@echo "       https://github.com/elasticlabs/headless-wordpress-docker-compose "
	@echo " "
	@echo " "
	@echo " Basic usage :"
	@echo "   make build           # Makes container & volumes cleanup, and builds the stack"
	@echo "   make up  (stop)      # With working proxy, brings up (or stop) the stack"
	@echo "   make update          # Update the whole stack"
	@echo " "
	@echo " Management utils :"
	@echo "   make toolbox         # Temporary run the WP CLI container for maintenance purpose"
	@echo "   make ssh <container> # Connects to internal <container> shell"
	@echo "   make mariadb_backup  # Backups mariaDB wordpress DB in backup/mysql.sql.gz"
	@echo "   make mariadb_restore # Restores mariaDB wordpress DB from backup/mysql.sql.gz"
	@echo "   make hard-cleanup    # Hard cleanup of images, containers, networks, volumes & data"
	@echo "======================================================================================"

.PHONY: up
up: build
	@echo " "
	@bash ./.utils/message.sh info "[INFO] Starting the project..."
	docker-compose up -d --remove-orphans ${SOFTWARE_STACK}
	@bash ./.utils/message.sh info "[INFO] Waiting for resources to become ready for configuration..."
	docker-compose run --rm healthcheck
	docker-compose run --rm toolbox configure
	@cp ./.toolbox/composer.json ./app/wordpress/
	docker-compose run --rm toolbox deploy-headless
	@make urls

.PHONY: build
build:
	# Refresh repository
	git stash && git pull
	# Build the stack
	@bash ./.utils/message.sh info "[INFO] Building the application"
	docker-compose build --pull ${WP_STACK}

.PHONY: update
update: 
	@bash ./.utils/message.sh info "[INFO] Updating the project..."
	docker-compose pull mariadb wordpress adminer
	@cp ./.toolbox/composer.json ./app/wordpress/
	docker-compose run --rm toolbox deploy-headless
	docker-compose up -d --remove-orphans proxy ${WP_STACK}
	make urls

.PHONY: urls
urls:
	@bash ./.utils/message.sh headline "[INFO] You may now access your project at the following URLs:"
	@bash ./.utils/message.sh link "Frontend:   https://${APP_BASEURL}/"
	@bash ./.utils/message.sh link "Backend:    https://${APP_BASEURL}/wp-admin/"
	@bash ./.utils/message.sh link "Adminer:    https://${APP_BASEURL}/adminer"
	@echo ""

.PHONY: toolbox
toolbox: 
	@bash ./.utils/message.sh headline "[INFO] Running the WP-CLI container :"
	@echo " "
	docker-compose run --rm toolbox /bin/bash

.PHONY: mariadb_backup
mariadb_backup:
	bash ./.utils/mysql-backup.sh

.PHONY: mariadb_restore
mariadb_restore:
	bash ./.utils/mysql-restore.sh

.PHONY: ssh
ssh:
	docker exec -it $$(docker-compose ps -q $(ARGS)) /bin/sh

.PHONY: stop
stop:
	@bash ./.utils/message.sh info "[INFO] Stopping the project..."
	docker-compose stop

.PHONY: hard-cleanup
hard-cleanup:
	@bash ./.utils/message.sh info "[INFO] Bringing down the Headless Wordpress Stack"
	docker-compose down --remove-orphans
	# 2nd : clean up all containers & images, without deleting static volumes
	@bash ./.utils/message.sh info "[INFO] Cleaning up containers & images"
	docker system prune -a
	# Delete all hosted persistent data available in local directorys
	@bash ./.utils/message.sh info "[INFO] Remove all stored logs and data in local volumes!"
	rm -rf app/*

.PHONY: wait
wait: 
	sleep 2