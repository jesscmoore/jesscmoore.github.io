---
layout: post
title:  "Deploy dash web app on caddy web server"
date:   2023-06-26 10:05:05 +1100
published: true
toc: true
---

Every new dashboard or web app requires a means to make it available. Deploying and sharing the app as it is being developed allows us to actively disseminate it to the non developer members of the team enabling them to actively participate in the project. First follow the instructions to [set up a caddy web server]({% post_url 2023-06-25-serve-website %}). Here I will show how to deploy a containerised dash web app onto an ubuntu server.


**Summary**

1. Define environment variables for the `debug`, `port` and `host` settings used for `app.run_server()` in dash
  ```
  echo "APP_HOST=0.0.0.0\nAPP_PORT=8090\nAPP_DEBUG=False" > .env
  ```

2. Disable website setting and instead setup reverse proxy for port used by dash app
  ```
  perl -pi -e "s|root * /var/www/html|# root * /var/www/html" /etc/caddy/Caddyfile
  perl -pi -e "s|# reverse_proxy localhost:80|reverse_proxy localhost:8090" /etc/caddy/Caddyfile
  systemctl reload caddy
  ```

3. In app: fetch and use configuration settings in your dash project
`constants.py`:
  ```
  APP_HOST = os.environ.get("APP_HOST")
  APP_PORT = int(os.environ.get("APP_PORT"))
  APP_DEBUG = bool(os.environ.get("APP_DEBUG"))
  ```
  `app.py`:
  ```
  server = app.server
  if __name__ == '__main__':
      app.run_server(port=APP_PORT,
                    debug=APP_DEBUG,
                    host=APP_HOST)
  ```

4. Create a `Dockerfile` and `docker-compose.yml`.
`Dockerfile`:
  ```
  FROM python:3.11
  ENV DASH_DEBUG_MODE $APP_DEBUG
  WORKDIR /app
  COPY . .
  RUN apt-get update && \
      apt-get --yes install build-essential python3-dev libmemcached-dev libldap2-dev libsasl2-dev libzbar-dev  ldap-utils tox lcov valgrind && \
      apt-get clean
  RUN set -ex && \
      pip install -e .
  EXPOSE $APP_PORT
  CMD gunicorn -w 4 -b $APP_HOST:$APP_PORT app:server --preload
  ```
`docker-compose.yml`:
  ```
  version: "3"
  services:
    dash:
      container_name: dash
      build:
        dockerfile: Dockerfile
        args:
          - APP_DEBUG=${APP_DEBUG}
          - APP_HOST=${APP_HOST}
          - APP_PORT=${APP_PORT}
      restart: unless-stopped # Do not keep starting if stopped by user
      environment:
        - APP_DEBUG
        - APP_PORT
        - APP_HOST
        - TZ=Australia/Canberra
      ports:
        - ${APP_PORT}:${APP_PORT}
      expose:
        - ${APP_PORT}
      networks:
        - default
      volumes:
        # allows host to get files downloaded in container
        - "./analytics:/app/analytics:rw"
  ```

5. Sync local repo to remote
  ```
  rsync -avz --stats --exclude-from='exclude-file.txt' . ade@$(SERVER):~/$(APP)/.
  ```

6. Build on remote
  ```
  ssh [user]@[remote]
  cd [project]
  sudo docker compose up --build --detach dash
  ```

7. Optionally setup a Makefile for streamlined syncing and container management



## Procedure

### Specify host and port

The dash app uses environment settings in `.env` which set the host and port used for the app, and turn debug mode off.

```
$ cat .env

# Production settings
APP_HOST=0.0.0.0
APP_PORT=8090
APP_DEBUG=False
```
These differ to the development settings of:
```
# Development settings
APP_HOST=127.0.0.1
APP_PORT=8091
APP_DEBUG=True
```

### Set up reverse proxy

The caddy server setup reverse proxy from the chosen domain name to the app port and reload the caddy server
```
perl -pi -e "s|root * /var/www/html|# root * /var/www/html" /etc/caddy/Caddyfile
perl -pi -e "s|# reverse_proxy localhost:80|reverse_proxy localhost:8090" /etc/caddy/Caddyfile
systemctl reload caddy
```
Afterwards `/etc/caddy/Caddyfile` should look like
```
[HOST_NAME] {
	# Set this path to your site's directory.
	# root * /var/www/html

	# Enable the static file server.
	file_server

	# Another common task is to set up a reverse proxy:
	reverse_proxy localhost:8090

	# Or serve a PHP site through php-fpm:
	# php_fastcgi localhost:9000
}
```

### In app: fetch configuration settings

In your `constants.py` within your app, fetch the configuration settings
```
APP_HOST = os.environ.get("APP_HOST")
APP_PORT = int(os.environ.get("APP_PORT"))
APP_DEBUG = bool(os.environ.get("APP_DEBUG"))
```

### In app: setup app.py

Gunicorn requires `server` parameter, `app.py` should look like:
```
# Local machine docker: Use debug=True
# Remote machine docker: Use debug=False, host=0.0.0.0
# Both: set server variable
server = app.server
if __name__ == '__main__':
    app.run_server(port=APP_PORT,
                   debug=APP_DEBUG,
                   host=APP_HOST)
```

### Test start of the app

Test start of the app in development mode on server
```
cd [project]
python3 -m pip install -e .
python3 ./app.py
```
Press `Ctrl-C` to exit app in dev mode



### Containerise with Docker

Create a `Dockerfile` with python which copies the project to `/app`, installs the package, runs the app on `localhost`:`8090` and exposes that port. Some of these ubuntu packages are only required if you setup your app to support ldap login.
```
FROM python:3.11

ENV DASH_DEBUG_MODE $APP_DEBUG
WORKDIR /app
COPY . .
# Required for python-ldap
RUN apt-get update && \
    apt-get --yes install build-essential python3-dev libmemcached-dev libldap2-dev libsasl2-dev libzbar-dev  ldap-utils tox lcov valgrind && \
    apt-get clean
RUN set -ex && \
    pip install -e .

EXPOSE $APP_PORT

CMD gunicorn -w 4 -b $APP_HOST:$APP_PORT app:server --preload
```

Create a `docker-compose.yml` for easy deployment as below. This sets the timezone within the container and retrieves the application settings `$APP_DEBUG`, `$APP_HOST` and `$APP_PORT` from `.env` and passes these as environment variables into the application container.
```
# Requires .env file
version: "3"
services:
  dash:
    container_name: dash
    build:
      dockerfile: Dockerfile
      args:
        - APP_DEBUG=${APP_DEBUG}
        - APP_HOST=${APP_HOST}
        - APP_PORT=${APP_PORT}
    restart: unless-stopped # Do not keep starting if stopped by user
    environment:
      - APP_DEBUG
      - APP_PORT
      - APP_HOST
      - TZ=Australia/Canberra
    ports:
      - ${APP_PORT}:${APP_PORT}
    expose:
      - ${APP_PORT}
    networks:
      - default
    volumes:
      # allows host to get files downloaded in container
      - "./analytics:/app/analytics:rw"
```


### Streamline container rebuild with Makefile

Using a Makefile we can simplify the commands by adding these rules to your Makefile.
```
app: denv
        python ./app.py $(SKIP_LOGIN)

sync:
        rsync -avz --stats --exclude-from='exclude-file.txt' . ade@$(SERVER):~/$(APP)/.

penv:
        cp -p environment/.env_prod .env

denv:
        cp -p environment/.env_dev .env

up:
	sudo docker compose up --build --detach dash

logs:
	sudo docker compose logs -f dash

stop:
	sudo docker compose stop dash

run:
	sudo docker compose up --detach dash

restart: stop up

ps:
        sudo docker compose ps

open:
        sudo docker exec -it dash bash

rmdash:
        sudo docker container rm dash

rmprune:
        sudo docker system prune

```
This will simplify deployment and container restart to two commands `make sync...` and `make restart`

On local machine in project
```
$ cd [project]
$ make sync server=[server_name]
```
On server
```
$ cd [project]
$ make restart
```

## Troubleshooting

Docker uses considerable space which can fill over time, especially with repeat builds. This excess docker artifacts can be deleted with
```
sudo docker system prune
```
shortened to
```
make rmprune
```

However docker space usage does continue to increases over time. The docker storage location is found with
```
sudo docker info | grep 'Docker Root Dir'
```
and by default is `/var/lib/docker`. You can manage docker space usage by moving docker to a [custom docker storage location]({% post_url 2023-11-10-move-docker-install %}) with a larger disk space, or removing and reinstalling docker.
