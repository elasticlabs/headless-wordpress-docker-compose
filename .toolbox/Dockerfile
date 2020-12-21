 
FROM wordpress:cli

# Install make tool
USER root
RUN apk add --no-cache curl make composer

# Make docker-compose wait for container dependencies be ready
# Add the wait script to the image
ENV WAIT_VERSION 2.7.2
ADD https://github.com/ufoscout/docker-compose-wait/releases/download/$WAIT_VERSION/wait /wait
RUN chmod +x /wait

# Add Makefile to scripts dir
ADD Makefile entrypoint.sh message.sh wordpress-ssl-fix.sh /scripts/
RUN chmod +x /scripts/entrypoint.sh

WORKDIR /var/www/html
ENTRYPOINT [ "/scripts/entrypoint.sh" ]

CMD ["wp", "shell"]