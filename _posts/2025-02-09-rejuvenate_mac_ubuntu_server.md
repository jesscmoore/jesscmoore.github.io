---
layout: post
title:  "Rejuvenate Old Mac as Ubuntu Server"
date:   2025-02-09 21:58:52 +1100
published: false
toc: true
---

A 10 year old Mac Air runs perfectly. However with only X RAM and Y storage it lacks the specs to support modern MacOS operating system. This is more than sufficient for Ubuntu server with basic tasks of serving network drives and a few small web apps that we require to be always up.

**Summary**

1. Unlink macbook - deauthorise macbook from your account services.
2. Download Ubuntu Server and create bootable disk.
3. Install Ubuntu Server from bootable USB.
4. Prevent sleep on lid closure.
5. Turn screen off.


## Procedure

### Unlink macbook

Follow these steps to [deauthorise machine]({% post_url 2025-02-04-mac_deauth_services %}) from services.


### Download and install Ubuntu Server

Open https://ubuntu.com/download/server and download the latest long term supported server. Follow Ubuntu's how to install instructions and step-by-step tutorial if useful. To enable ethernet setup, ensure laptop is connected to modem via ethernet before starting install wizard. This ensures an internet connection in cases where the wifi network controller is not recognised by the Ubuntu OS and requires later install of a driver.


### Install ssh server

To enable remote access with ssh, install ssh server.

```bash
sudo apt update
sudo apt install openssh-server
```

The ssh server should now be installed and can be verified with:

```bash
sudo systemctl status ssh
```


### Prevent sleeping

Next, disable laptop from entering suspend mode when lid is closed. See how to edit the login configuration to [prevent sleeping on lid closure]({% post_url 2025-02-09-stop_server_sleeping %}).

### Turn screen off

Finally, there is no need to have the laptop display on, as the machine is now always accessed from remote login. Follow how to [turn the screen off]({% post_url 2025-02-09-turn_screen_off %}) to disable the screen.


**References**

- [https://medium.com/@t.deb41/how-to-turn-your-old-macbook-into-a-home-server-2bb04a5277f7](https://medium.com/@t.deb41/how-to-turn-your-old-macbook-into-a-home-server-2bb04a5277f7) - on how to setup as server
