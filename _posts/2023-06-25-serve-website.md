---
layout: post
title:  "How to setup caddy web server and deploy a website"
date:   2023-06-25 13:05:05 +1100
published: true
toc: true
---

For simplicity, we use a caddy web server deployed on ubuntu. For external access to a domain name, you will need to register a domain name and obtain an SSL certificate.

**Summary**

1. Install and start caddy web server.
```
apt-get install --yes debian-keyring debian-archive-keyring apt-transport-https
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/caddy-stable.list
apt-get update
apt-get install --yes caddy
systemctl enable caddy
systemctl start caddy
```

2. Confgiure caddy by editing the `/etc/caddy/Caddyfile` to serve website at `/var/www/html` to your ip address or domain name, and add a default web page.
```
HOST_NAME=`hostname`
perl -pi -e "s|^:80|${HOST_NAME}|" /etc/caddy/Caddyfile
perl -pi -e "s|/usr/share/caddy|/var/www/html|" /etc/caddy/Caddyfile
mkdir -p /var/www/html
echo "Server Deployed $(date)" | sudo tee /var/www/html/index.html
systemctl reload caddy
```

3. Test externally accessible on that domain or ip address.

```
$ curl https://[HOST_NAME]
Server Deployed Thu  6 Apr 2023 02:27:03 AEST
```

## Procedure

### Install and start caddy web server


```
apt-get install --yes debian-keyring debian-archive-keyring apt-transport-https
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/caddy-stable.list
apt-get update
apt-get install --yes caddy
systemctl enable caddy
systemctl start caddy
systemctl status caddy
```

### Configure caddy

Confgiure caddy by editing the `/etc/caddy/Caddyfile` to serve content to the hostname (ip address or domain name) of your server.
```
HOST_NAME=`hostname`
perl -pi -e "s|^:80|${HOST_NAME}|" /etc/caddy/Caddyfile
```

Define website location as `/var/www/html` and create a default webpage to test webserver. Note caddy has to be reloaded to implement changes to the Caddyfile.
```
perl -pi -e "s|/usr/share/caddy|/var/www/html|" /etc/caddy/Caddyfile
mkdir -p /var/www/html
echo "Server Deployed $(date)" | sudo tee /var/www/html/index.html
systemctl reload caddy
```

### Test local access

Test web service localling by adding a second block for serving `/var/www/html/` as localhost

```
http:// {
        # Set this path to your site's directory.
        root * /var/www/html

        # Enable the static file server.
        file_server

        # Another common task is to set up a reverse proxy:
        # reverse_proxy localhost:80

        # Or serve a PHP site through php-fpm:
        # php_fastcgi localhost:9000
}
```
Restart web server and download `index.html` with `curl`
```
systemctl reload caddy
curl http://localhost
```
You should see
```
Server Deployed Thu  6 Apr 2023 02:27:03 AEST
```

### Test wwww aaccessible
Now from another machine, test the web server is working and that a valid SSL certificate for your domain is installed on your server. Here [HOST_NAME] would be replaced with the domain name of your server.

```
$ curl https://[HOST_NAME]
Server Deployed Thu  6 Apr 2023 02:27:03 AEST
```
For details of certificate use:
```
curl -vv https://[HOST_NAME]
* Server certificate:
*  subject: CN=[HOST_NAME]
*  start date: Jun  4 14:27:31 2023 GMT
*  expire date: Sep  2 14:27:30 2023 GMT
*  subjectAltName: host "[HOST_NAME]" matched cert's "[HOST_NAME]"
*  issuer: C=US; O=Let's Encrypt; CN=R3
*  SSL certificate verify ok.
```

This confirms that your web site is accessible from across the world wide web. Edit your `Caddyfile` to remove the http access to your website to limit it to your domain only. It should look like below, where [HOST_NAME] is the domain name of your server.
```
[HOST_NAME] {
        # Set this path to your site's directory.
        root * /var/www/html

        # Enable the static file server.
        file_server

        # Another common task is to set up a reverse proxy:
        # reverse_proxy localhost:80

        # Or serve a PHP site through php-fpm:
        # php_fastcgi localhost:9000
}
```
```
systemctl reload caddy
systemctl status caddy
```
You are now ready to deploy your website to `/var/www/html` by installing your website or web app repo on the server, building your website/webapp, and rsyncing it to `var/www/html`


**References**

Refer to the Caddy docs for more information:

https://caddyserver.com/docs/caddyfile
