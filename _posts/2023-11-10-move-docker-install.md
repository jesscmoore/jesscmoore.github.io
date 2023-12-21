---
layout: post
title:  "How to move docker to another logical volume on Ubuntu"
date:   2023-11-12 18:23:03 +1100
categories: ubuntu
published: true
toc: true
---

**Summary**

We want to remove docker and reinstall it with configuration settings to install it on a larger logical volume.


1. Stop docker service
```
systemctl stop docker
```

2. Manually configure the docker storage location in new docker config file. We will use to environment variables, and edit the docker configuration file `vim /etc/docker/daemon.json` with the value of the new docker root storage location.
```
docker_dir=/opt/dash/docker
old_docker_dir=/var/lib/docker
```
echo > `vim /etc/docker/daemon.json` to your new install location.

```
{
  "data-root": "${docker_dir}"
}
```

3. Stop docker service and sync docker files to new storage location /opt/dash/docker
```
systemctl stop docker
mkdir -p ${docker_dir}
rsync -axPS ${old_docker_dir}/ ${docker_dir}
systemctl start docker
docker info | grep 'Docker Root Dir'
```

4. Now the old docker location can be removed
```
rm -r ${old_docker_dir}
```


## Procedure

### Check docker install location

Using `docker info` we see that docker root directory is at `/var/lib/docker`. This is where docker artifacts are stored.
```
$ docker info |grep 'Docker Root Dir'

Docker Root Dir: /var/lib/docker
```

## Stop and remove docker

First stop containers, and stop and remove docker
```
docker compose stop dash
systemctl stop docker
apt-get purge docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-ce-rootless-extras
rm -rf /var/lib/docker
rm -rf /var/lib/containerd
```
Check `/var` disk usage
```
df -Th
```
`/var` has reduced from being 86% full to only 13% full.

## Install docker

docker_dir=/opt/dash/docker
old_docker_dir=/var/lib/docker
docker_config=/etc/docker/daemon.json

Install docker
```
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update
apt-get install --yes docker-ce docker-ce-cli containerd.io docker-compose-plugin
service docker start
```

## Configure docker and move docker installation


Set docker root directory
```
mkdir -p ${docker_dir}
```
Add `data-root` setting to `/etc/docker/daemon.json`

```
$ vim daemon.json

{
  "data-root": "${docker_dir}",
}
```

```
systemctl stop docker

mkdir -p ${docker_dir}

rsync -axPS ${old_docker_dir}/ ${docker_dir}

systemctl start docker
docker info | grep 'Docker Root Dir'
```

Now the old docker location can be removed

```
rm -r ${old_docker_dir}
```

Now as non su user, test docker by rebuilding and starting a docker container of your choice.
