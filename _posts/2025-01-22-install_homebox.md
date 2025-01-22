---
layout: post
title:  "How to setup Homebox"
date:   2025-01-22 16:27:47 +1100
published: false
toc: true
---

How to install and setup Homebox home inventory manager

**Summary**

1. [command] - 1 line explanation
2. [command] - 1 line explanation

## Procedure

### Install

There are two options:

1. Running the latest docker container image with docker-compose
2. Installing the binary from [github](https://github.com/sysadminsmedia/homebox/releases)

Here we try the binary `homebox_Linux_armv6.tar.gz` which we downloaded from the releases webpage on github, and scp to our server. We are trying out Homebox on our Raspberry Pi 3b server that is also used for running OpenHAB, which is a very lightweight machine with only 1GB RAM and 64GB of storage.

```
scp homebox_Linux_armv6.tar.gz jmoore@raspberrypi.local:~/.
ssh jmoore@raspberrypi
```

```
jmoore@raspberrypi:~ $ tar -zxvf homebox_Linux_armv6.tar.gz
homebox
```

Let's check we have the correct binary for our RPI armv71 archiracture. This shows its 32-bit for ARM compatible architectures which should work for us.

```
jmoore@raspberrypi:~ $ file homebox
homebox: ELF 32-bit LSB executable, ARM, EABI5 version 1 (SYSV), statically linked, Go BuildID=vACefrM87eWn5Pd3PkJh/VP6adiOdOvEizLURtlAA/cUMqhH5wEHzHYl247zD3/1CahodI08aUH7SGONmp3, stripped
```

Run Homebox with
```
jmoore@raspberrypi:~ $ ./homebox
4:24PM INF ../../workspaces/homebox/backend/app/api/handlers/v1/v1_ctrl_auth.go:98 > registering auth provider name=local
4:24PM INF ../../workspaces/homebox/backend/app/api/main.go:204 > Server is running on :7745
...
```

In retrospect I should have run it in the background.


For other users to see your items and locations, they will need to sign up using our invite link, otherwise they will only see their own items. An invite can be sent to others with:

Go to the `Profile` in the left navigation bar > `User Profile` > click `Generate Invite Link`

### Testing

Navigating to http://raspberrypi.local:7745/ shows the homebox login and signup webpage.


#### TEST 0: Access from Android mobile with Chrome app

Created first item NodeMCU v3 ESP8266 chip  from MacOS Chrome browser. Login from Android mobile on LAN shows same item.


#### TEST 1: Item is persisted after closing the app

`Ctrl-C` out of the app.

`ps -ef |grep homebox` to confirm no homebox running

`./homebox` to restart

On 3rd homebox app restart, previously created item as accessible and editable from macos and android os, and photo added from android os chrome app.

 Binary app sometimes crashes shortly after restart.


**LOOKS LIKE NEED TO RUN ON MORE POWERFUL SERVER**

#### TEST 2: Item can be moved from one location to another

Yes. Moved item from MJ Bedroom to Living Room.

### Install homebox on MacOS

```
mkdir homebox
cd homebox
create_repo here
code .
touch docker-compose.yml
```


Added following to docker-compose.yml:
```
services:
  homebox:
    image: ghcr.io/sysadminsmedia/homebox:latest
    #   image: ghcr.io/sysadminsmedia/homebox:latest-rootless
    container_name: homebox
    restart: always
    environment:
      - HBOX_LOG_LEVEL=info
      - HBOX_LOG_FORMAT=text
      - HBOX_WEB_MAX_UPLOAD_SIZE=10
    volumes:
      - homebox-data:/data/
    ports:
      - 3100:7745

volumes:
  homebox-data:
    driver: local
```

Started the homebox container with:

```
$  docker compose up --detach
[+] Running 6/6
 ✔ homebox Pulled                                                                                                                                                    9.9s
   ✔ 52f827f72350 Pull complete                                                                                                                                      2.5s
   ✔ 18f8e1587256 Pull complete                                                                                                                                      2.5s
   ✔ 028ab5f3379e Pull complete                                                                                                                                      2.6s
   ✔ 612af5fccf41 Pull complete                                                                                                                                      6.1s
   ✔ 4f4fb700ef54 Pull complete                                                                                                                                      6.1s
[+] Running 3/3
 ✔ Network homebox_default        Created                                                                                                                            0.0s
 ✔ Volume "homebox_homebox-data"  Created                                                                                                                            0.0s
 ✔ Container homebox              Started                                                                                                                            0.4s

Let's check container status:

```
$ docker compose ps
NAME      IMAGE                                   COMMAND                  SERVICE   CREATED              STATUS                        PORTS
homebox   ghcr.io/sysadminsmedia/homebox:latest   "/app/api /data/conf…"   homebox   About a minute ago   Up About a minute (healthy)   0.0.0.0:3100->7745/tcp
```

Logs show successful startup!

```
$ docker compose logs homebox
homebox  | 11:25AM INF ../go/src/app/app/api/handlers/v1/v1_ctrl_auth.go:98 > registering auth provider name=local
homebox  | 11:25AM INF ../go/src/app/app/api/main.go:204 > Server is running on :7745
```

### Create user

Registered main user with my email address on http://10.1.1.195:3100/

### Import inventory

Uploaded the previously exported inventory csv file at:

`Tools` > click `Import Inventory`

### Testing

Accessible to edit from Android OS and MacOS machines using chrome browser. Quick page loading with homebox container running off my macOS.

Inspection of the `docker compose logs homebox` shows no errors.


### Configuration

User registration can be turned off by adding below to docker-compose.yml:
```
- HBOX_OPTIONS_ALLOW_REGISTRATION=false
```

Reverse proxy for host server can be setup also, see this script which also covers docker, portainer and nproxy-manager install - https://gitlab.com/bmcgonag/docker_installs/-/raw/main/install_docker_nproxyman.sh


### Back up

Regular backups should be setup. These can be done by exporting the db to csv.

**References**

- [https://github.com/sysadminsmedia/homebox]
- [https://homebox.software/en/]
- [https://github.com/sysadminsmedia/homebox/releases] - binary and source code releases
- https://medium.com/daniels-tech-world/getting-my-life-organised-with-homebox-open-source-inventory-management-d5583d4c4248
- https://gitlab.com/bmcgonag/docker_installs/-/raw/main/install_docker_nproxyman.sh - script
