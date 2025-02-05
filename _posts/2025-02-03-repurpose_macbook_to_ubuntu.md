---
layout: post
title:  "Repurpose macbook with ubuntu desktop"
date:   2025-02-03 20:58:17 +1100
published: false
toc: true
---

My older 2017 Macbook Pro running MacOS Big Sur with 8GB RAM and 250GB storage is still a perfectly good machine but struggles with load in the MacOS environment and cannot be upgraded as the MacOS Venturer and above do not support this 2017 Macbook Pro and earlier models. I've been wanting to transition our everyday laptops to linux so Ubuntu Desktop 24.04.1 LTS here goes.

**Summary**

1. Deauthorise machine - disconnect it from your account services.
2. `Balena Etcher` - to burn downloaded Ubuntu Desktop iso to bootable flash drive.
3. [Reboot from bootable USB] - run Ubuntu install wizard.
4. Install

## Procedure

### Deauthorise from services

Follow these steps to [deauthorise machine]({% post_url 2025-02-04-mac_deauth_services %}) from services.


### Create Ubuntu bootable USB

Use the Balena Etcher app to easily create a bootable install disk from the downloaded Ubuntu iso.

### Install Ubuntu Desktop

After deauthorising the computer from key services, reboot into boot mode clicking `Restart` and holding `Option` key when screen goes blank.

Select `boot` disk and follow the install wizard.

When installation complete, reboot, and remove the USB with the boot image.

The machine should now boot into the Ubuntu login screen.

#### Wifi

During install, select wifi network and add credentials.


### OpenSSH Server

Install `OpenSSH Server` to allow remote login and management. Openssh server is inactive until started.

```
sudo apt-get update
sudo apt-get install openssh-server
sudo systemctl status ssh
```

The system config options are specified in `/etc/ssh/sshd_config`, with commented options showing the default value. OpenSSH server reads this system config file and any additional configs in `/etc/ssh/sshd_config.d/*.conf`. `man sshd_config` for more info. Unless noted otherwise, for each keyword, the first obtained value is used. For this reason, we add our settings to a separate conf file.

```
sudo vim /etc/ssh/sshd_config.d/50-cloud-init.conf
```
with contents:
```
PasswordAuthentication no
#PermitRootLogin prohibit-password
```

First test sshd configuration before starting, which gave an error.

```
sudo sshd -t -f /etc/ssh/sshd_config
Missing privilege separation directory: /run/sshd
```

Following https://askubuntu.com/questions/1110828/ssh-failed-to-start-missing-privilege-separation-directory-var-run-sshd created expected directory, after which the sshd check ran with no hiccups.

```
sudo mkdir -p /var/run/sshd
sudo chmod 0755 /var/run/sshd
sudo sshd -t -f /etc/ssh/sshd_config
```

Started ssh server with:;

    $ sudo systemctl enable ssh

this creates symlinks from `/etc/systemd/system/sshd.service -> /etc/lib/systemd/system/ssh.service`

    $ sudo ststemctl restart ssh
    $ sudo systemctl status ssh

shows ssh is "active (running)" !!

We can now login directly authenticating by password with

    $ ssh user@host

or
    $ ssh user@host_ip


#### Passwordless ssh

Switch to passwordless ssh for improved security.

First get our public key from github:

    $ ssh-import-id-gh <gh_username>

To enable passwordless ssh as root, also copy to `/root/.ssh/`:

```bash
sudo sed -i '$a '"`cat /home/<adminusername>/.ssh/authorized_keys`" /root/.ssh/authorized_keys
```

The default ssh configuration to protect root login is `PermitRootLogin prohibit-password`. To abide with this, now that key authentication is setup, edit our ssh config to turn off PasswordAuthentication.

    $ sudo vi /etc/ssh/sshd_config.d/50-cloud-init.conf

and change line to:

    PasswordAuthentication no

Apply by restarting ssh

    $ sudo systemctl restart ssh
    $ sudo systemctl status ssh

We can now successfully login as user or root without password.

```bash
ssh user@<hostname>
```

Test ssh as root from client returns root home directory:

```bash
ssh -q root@<hostname> pwd
logout
```











#### Setup ssh authentication with public-private key pair



### Remote setup and configure

This covers a range of steps to install useful apps (including setting up a cronjob for updates), add firewall, and install user's apps and configuration.

The last step installs the user's `.bashrc`, other dot files and scripts folder to the new machine, and rsyncs the scripts folder of the administrator to each user.

- install required apps (including cronjob for nightly updates)
- add fail2ban
- disable ssh password login
- allow sudo no passwd (for some users)
- add firewall
- install user apps and config


**TO BE DONE:** setup backup to networked drive


**References**

- [https://ubuntu.com/server/docs/openssh-server]
- https://medium.com/wearetheledger/oh-my-zsh-made-for-cli-lovers-installation-guide-3131ca5491fb
- https://ohmyz.sh/
- https://github.com/ohmyzsh/ohmyzsh/wiki/Installing-ZSH
- https://www.ubuntumint.com/install-zsh-oh-my-zsh-powerlevel10k-ubuntu/
