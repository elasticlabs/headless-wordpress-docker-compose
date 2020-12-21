FROM php:7.4-cli-alpine

RUN apk add --no-cache curl make composer

# Install WP-CLI in the toolbox
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar  \
    && chmod +x wp-cli.phar  \
    && mv wp-cli.phar /usr/local/bin/wp-cli \
    # Install MySQL extension, as WP-CLI needs to access to WordPress database
    && docker-php-ext-install mysqli

# Add Makefile to scripts dir
ADD Makefile /scripts/Makefile
ADD composer.json /var/www/html/composer.json

WORKDIR /var/www/html
ENTRYPOINT [ "make", "-f", "/scripts/Makefile" ]  