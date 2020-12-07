# Headless Wordpress with NGinx reverse proxy in docker-compose
This project is a docker composition of a headless wordpress stack, providing a GraphQL API to React based serverless frameworks.

- HTTPS with `Let's Encrypt` SSL enabled option using an [automated HTTPS Nginx reverse proxy](https://github.com/elasticlabs/https-nginx-proxy-docker-compose) for your containers.
- Inspired by the following series of articles : [Using Wordress as a headless CMS for NextJS](https://dev.to/kendalmintcode/configuring-wordpress-as-a-headless-cms-with-next-js-3p1o)

**What is Headless WordPress?** 

- [Wordpress](https://wordpress.org) is open source software you can use to create a beautiful website, blog, or app.
- It's CMS functionalities are perfect match for customers and content creators... 
- ... but gets really heavy, bloated, and rigid for frontend developpers.
- **Solution** : welcome API based, headless CMS! More explainations here : [Headless CMS explained](https://www.storyblok.com/tp/headless-cms-explained)
