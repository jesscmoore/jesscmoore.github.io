---
layout: post
title:  "Setup basic ufw firewall"
date:   2025-02-01 11:06:06 +1100
published: false
toc: true
---

Basis firewall commands using `ufw`, Ubuntu's Uncomplicated FireWall.

**Summary**

1. `sudo ufw logging on` - Setup logging
2. `sudo ufw enable` - Start firewall


## Procedure

### Allow ssh

    sudo ufw allow ssh/tcp

### Enable logging

If logging on, logs will be written to `/var/log/messages`, `/var/log/syslog`, and `/var/log/kern.log`.

    $ sudo ufw logging on

Logging behavior can be modified by editing /etc/syslog.conf.

### Enable firewall

By default, ufw is disabled in ubuntu. If adding firewall remotely, make sure to allow ssh/tcp before enabling firewall

    $ sudo ufw enable

By default, coming connections are denied and outgoing connections are allowed.

### View status

There are various ways to view status

- `sudo ufw status verbose` - verbose output shows status including logging and more detail
- `sudo ufw status numbered` - show rules with number index to allow referencing rules with their number

- `sudo systemctl status ufw.service` - how is this difference to ufw status
- `sudo ufw reset` -
- `sudo ufw reload` -


### Application rules

Applications that require network connections will often include a ufw profile that is installed when the application is installed, e.g. OpenSSH

List installed ufw application profiles, shows an application profile for openSSH.

    $ sudo ufw app list`
    Available applications:
      OpenSSH

View the application profile for openSSH:

    $ sudo ufw app info OpenSSH
    Profile: OpenSSH
    Title: Secure shell server, an rshd replacement
    Description: OpenSSH is a free implementation of the Secure Shell protocol.

    Port:
    22/tcp

Allow the openSSH application profile, will add it to our configuration:

    $ sudo ufw allow "OpenSSH"

This is equivalent to `sudo ufw allow ssh/tcp`.


### Allow other application ports

Applications communicate with specific ports. To allow incoming traffic from these applications we need to add rules that allow incoming traffic on those ports. Default ports used by common applications.

    http: 80
    https: 443
    rsync: 873
    samba:
    mysql: 3306
    postgresql: 5432
    smtp: 25
    nginx: 80, 443
    caddy: 80, 443
    apache: 80, 443

Or alternatively, if the application has provided a ufw application profile,  we can enable it's application profile.

    $ sudo ufw allow Samba

We will need to open other ports to incoming connections if we are serving web apps on other ports.

### Limiting traffic to local area network

    $ sudo ufw allow from 10.1.1.0/24

This allows traffic on all ports from ip addresses in range 10.1.1.0 to 10.1.1.255 used by our local area network. However it is better practise to limit traffic from machines on our LAN to specific ports.

### Other useful commands

- `--dry-run` - Option to show the rules created by a command without applying them.
- `sudo ufw disable && sudo ufw enable` - Restart firewall. Required to apply changes after rules have been changed.


**References**

- [https://documentation.ubuntu.com/server/how-to/security/firewalls/?_ga=2.247680256.624557524.1738289486-87986788.1737882244&_gl=1*130q69z*_gcl_au*NjIyNTk5MzczLjE3Mzc4ODIyNjc.]
- [https://manpages.ubuntu.com/manpages/noble/en/man8/ufw.8.html]
