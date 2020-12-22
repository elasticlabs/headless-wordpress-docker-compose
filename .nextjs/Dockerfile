FROM node:lts-buster-slim

WORKDIR /usr/src/app

# Add scripts & dir
ADD entrypoint.sh /scripts/
RUN chmod +x /scripts/*.sh

ENTRYPOINT [ "/scripts/entrypoint.sh" ]
CMD ["npm", "run", "dev"]