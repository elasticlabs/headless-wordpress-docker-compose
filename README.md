# Headless Wordpress with NGinx reverse proxy in docker-compose
This project is a docker composition of a headless wordpress stack, providing a GraphQL API to React based serverless frameworks. Inspired by the following series of articles : [Using Wordress as a headless CMS for NextJS](https://dev.to/kendalmintcode/configuring-wordpress-as-a-headless-cms-with-next-js-3p1o)

**What is Headless WordPress?** 
- [Wordpress](https://wordpress.org) is open source software you can use to create a beautiful website, blog, or app.
- It's CMS functionalities are perfect match for customers and content creators... 
- ... but gets really heavy, bloated, and rigid for frontend developpers.
- **Solution** : welcome API based, headless CMS! More explainations here : [Headless CMS explained](https://www.storyblok.com/tp/headless-cms-explained)

**Table Of Contents:**
  - [Docker environment preparation](#docker-environment-preparation)
  - [Headless wordpress deployment preparation](#headless-wordpress-deployment-preparation)
  - [Stack deployment and management](#stack-deployment-and-management)

----

## Docker environment preparation 
This stack is meant to be deployed behind an automated NGINX based HTTPS proxy. The recommanded automated HTTPS proxy for this stack is the [Elasticlabs HTTPS Nginx Proxy](https://github.com/elasticlabs/https-nginx-proxy-docker-composee). This composition repository assumes you have this environment :
* Working HTTPS Nginx proxy using Let'sencrypt certificates
* A local docker LAN network called `revproxy_apps` for hosting your *bubble apps* (Nginx entrypoint for each *bubble*). 

**Once you have a HTTPS reverse proxy**, navigate to the  [next](#teamengine-deployment-preparation) section.

## Headless wordpress deployment preparation :
* Choose & register a DNS name (e.g. `wordpress.your-domain.ltd`). Make sure it properly resolves from your server using `nslookup`commands.
* Carefully create / choose an appropriate directory to group your applications GIT reposities (e.g. `~/AppContainers/`)
* GIT clone this repository `git clone https://github.com/elasticlabs/headless-wordpress-docker-compose.git`
* Modify the following variables in `.env-changeme` file :
  * `TE_VHOST=` : replace `wordpress.your-domain.ltd` with your choosen subdomain for portainer.
  * `LETSENCRYPT_EMAIL=` : replace `email@mail-provider.ltd` with the email address to get notifications on Certificates issues for your domain. 
* **Rename `.env-changeme` file into `.env`** to ensure `docker-compose` gets its environement correctly.


## Stack deployment and management
**Deployment**
* Get help : `sudo make help`
* Bring up the whole stack : `sudo make build && sudo make up`
* Head to **`http://wordpress.your-domain.ltd`** and enjoy your Headless Wordpress!
* For database administration, head to **`http://wordpress.your-domain.ltd/adminer`** to manage `mariadb` using [Adminer](https://www.adminer.org/)

**Useful management commands**
* Go inside a container : `sudo docker-compose exec -it <service-id> bash` or `sh`
* See logs of a container: `sudo docker-compose logs <service-id>`
* Monitor containers : `sudo docker stats` or... use portainer!