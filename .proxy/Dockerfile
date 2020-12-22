FROM nginx:alpine

COPY uploadsize.conf /etc/nginx/conf.d/uploadsize.conf
COPY wp-revproxy.conf /etc/nginx/conf.d/wp-revproxy.conf

RUN sed -i "s/changeme/$VIRTUAL_HOST/" /etc/nginx/conf.d/wp-revproxy.conf