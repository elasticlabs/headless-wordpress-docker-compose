FROM node:alpine

WORKDIR /usr/src/app

# Add scripts & dir
COPY .gitignore .
ADD entrypoint.sh /scripts/
RUN chmod +x /scripts/*.sh

ENTRYPOINT [ "/scripts/entrypoint.sh" ]
CMD ["npm", "run", "dev"]