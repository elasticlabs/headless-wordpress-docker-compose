# 
# Headless wordpress - toolbox makefile
# 
WP_CLI=wp --allow-root

configure: 
	@bash /scripts/message.sh info "⚙️ Wordpress database settings..."
	@mv wp-config.php wp-config.old.php
	$(WP_CLI) core config \
		--dbhost=${WORDPRESS_DB_HOST} \
		--dbname=${WORDPRESS_DB_NAME} \
		--dbuser=${WORDPRESS_DB_USER} \
		--dbpass=${WORDPRESS_DB_PASSWORD} \
		--locale=${WORDPRESS_LOCALE} \
		--dbprefix=whebfubwef_\
		--skip-check

	@echo " "
	@bash /scripts/message.sh warning "⚙️ [UNSTABLE] Fix WP CLI messing with SSL management in wp-config-php..."
	sed -i '1,/table_prefix/!d ' wp-config.php
	sed '/table_prefix/,\$!d ' wp-config.old.php | grep -v table_prefix >> wp-config.php
	
	@bash /scripts/message.sh info "⚙️ Wordpress DB Creation..."
	$(WP_CLI) db create || true

	@bash /scripts/message.sh info "⚙️ Wordpress installation..."
	$(WP_CLI) core install \
		--url="https://${VIRTUAL_HOST}" \
		--title="$(WORDPRESS_WEBSITE_TITLE)" \
		--admin_user=${WORDPRESS_ADMIN_USER} \
		--admin_password=${WORDPRESS_ADMIN_PASSWORD} \
		--admin_email=${WORDPRESS_ADMIN_EMAIL}

	$(WP_CLI) option update siteurl "https://${VIRTUAL_HOST}"
	$(WP_CLI) option update home "https://${VIRTUAL_HOST}"
	$(WP_CLI) rewrite structure ${WORDPRESS_WEBSITE_POST_URL_STRUCTURE}

deploy-headless:
	@cd /var/www/html
	@echo "⚙️ ${VIRTUAL_HOST} site plugins deployment..."
	composer install --working-dir=/var/www/html --ignore-platform-reqs
	@echo "[INFO] Manual deployment of github hosted plugins."
	# WP GraphQL for ACF
	wp plugin install https://github.com/wp-graphql/wp-graphql-acf/archive/master.zip --force
	@echo "[INFO] List of deployed plugins :"
	$(WP_CLI) plugin list