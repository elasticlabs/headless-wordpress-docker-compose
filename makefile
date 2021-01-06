# Set default no argument goal to help
.DEFAULT_GOAL := help

# Ensure that errors don't hide inside pipes
SHELL         = /bin/bash
.SHELLFLAGS   = -o pipefail -c

#
# For cleanup, get Compose project name from .env file
APP_PROJECT?=$(shell cat .env | grep COMPOSE_PROJECT_NAME | sed 's/.*=//')
APP_BASEURL?=$(shell cat .env | grep VIRTUAL_HOST | sed 's/.*=//')
SOFTWARE_STACK = proxy wordpress mariadb adminer
WP_STACK = wordpress mariadb healthcheck toolbox
#
# Frontend Git repository specific variables
GIT_USER=$(shell cat .env | grep GIT_USER | sed 's/.*=//')
GIT_PASSWORD=$(shell cat .env | grep GIT_PASSWORD | sed 's/.*=//')
GIT_REPO=$(shell cat .env | grep GIT_REPO | sed 's/.*=//')
REPO_DIR=$(shell basename ${GIT_REPO}  | sed 's/\.git//')

# Every command is a PHONY, to avoid file naming confliction.
.PHONY: help
help:
	@echo "====================================================================================="
	@echo "                   Headless Wordpress docker composition "
	@echo "       https://github.com/elasticlabs/headless-wordpress-docker-compose "
	@echo " "
	@echo " "
	@echo " Backend commands :"
	@echo "   make build           # Makes container & volumes cleanup, and builds the stack"
	@echo "   make up  (stop)      # With working proxy, brings up (or stop) the stack"
	@echo "   make update          # Update the whole stack"
	@echo " "
	@echo " Frontent commands :"
	@echo "   make build-front     # Build dev NextJS frontend container"
	@echo "   make up-front        # Starts the Frontend application (whole stack, if not done yet)"
	@echo " "
	@echo " Management utils :"
	@echo "   make toolbox         # Temporary run the WP CLI container for maintenance purpose"
	@echo "   make ssh <container> # Connects to internal <container> shell"
	@echo "   make mariadb_backup  # Backups mariaDB wordpress DB in backup/mysql.sql.gz"
	@echo "   make mariadb_restore # Restores mariaDB wordpress DB from backup/mysql.sql.gz"
	@echo "   make hard-cleanup    # Hard cleanup of images, containers, networks, volumes & data"
	@echo "======================================================================================"

.PHONY: up
up: build build-front
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
	#git stash && git pull
	# 1/ Wordpress 
	# Set server_name in reverse proxy
	sed -i "s/changeme/${APP_BASEURL}/" .proxy/wp-revproxy.conf
	# Build the stack
	@bash ./.utils/message.sh info "[INFO] Building the application"
	docker-compose build --pull ${WP_STACK}

.PHONY: build-front
build-front:
	# Grab repo dir name and setup appropriate variable into .env file before build
	@bash ./.utils/message.sh info "[INFO] Setting up frontend container..."
	grep -q NEXTJS_DATA .env || echo "NEXTJS_DATA=./${REPO_DIR}" >> .env
	docker-compose build --pull nextjs
	# Build the Next JS site
	@bash ./.utils/message.sh info "[INFO] Building up NextJS demo / dev site..."
	git clone ${GIT_REPO} && chmod -R o+w ${REPO_DIR}
	grep -q ${REPO_DIR} .gitignore || echo ${REPO_DIR} >> .gitignore
	cd ${REPO_DIR} && docker-compose run --rm nextjs install

.PHONY: up-front
up-front: up
	@bash ./.utils/message.sh info "[INFO] Starting the Next JS dev site..."

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
	@bash ./.utils/message.sh link "next JS devsite: https://${APP_BASEURL}/"
	@bash ./.utils/message.sh link "WP Backend:      https://${APP_BASEURL}/wp-admin/"
	@bash ./.utils/message.sh link "Adminer:         https://${APP_BASEURL}/adminer/"
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
	# Cleanup .env file and move it to .env-changeme for initial checkup
	grep -v NEXTJS_DATA .env > .env-cleanup && rm .env
	@bash ./.utils/message.sh warning "[NOTICE] .env file moved to .env-cleanup -> Review & move it to .env when ready."
	
.PHONY: wait
wait: 
	sleep 2