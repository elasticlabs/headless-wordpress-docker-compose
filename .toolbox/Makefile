# 
# Headless wordpress - toolbox makefile
# 
WP_CLI=wp-cli --allow-root

configure: 
	@echo "⚙️ Wordpress database settings..."
	@rm -f wp-config.php
	$(WP_CLI) core config \
		--dbhost=${WORDPRESS_DB_HOST} \
		--dbname=${WORDPRESS_DB_NAME} \
		--dbuser=${WORDPRESS_DB_USER} \
		--dbpass=${WORDPRESS_DB_PASSWORD} \
		--locale=${WORDPRESS_LOCALE} \
		--skip-check

	@echo "⚙️ Wordpress site specific global settings..."
	$(WP_CLI) core install \
		--url=${VIRTUAL_HOST} \
		--title="$(WORDPRESS_WEBSITE_TITLE)" \
		--admin_user=${WORDPRESS_ADMIN_USER} \
		--admin_password=${WORDPRESS_ADMIN_PASSWORD} \
		--admin_email=${WORDPRESS_ADMIN_EMAIL}

	$(WP_CLI) option update siteurl "https://${VIRTUAL_HOST}"
	$(WP_CLI) rewrite structure $(WORDPRESS_WEBSITE_POST_URL_STRUCTURE)

deploy-plugins:
	@echo "⚙️ ${VIRTUAL_HOST} site plugins deployment..."
	composer install --working-dir=/var/www/html --ignore-platform-reqs
	@echo "[INFO] Manual deployment of ithub hosted plugins."
	# WP GraphQL for ACF
	wp plugin install https://github.com/wp-graphql/wp-graphql-acf/archive/master.zip --force