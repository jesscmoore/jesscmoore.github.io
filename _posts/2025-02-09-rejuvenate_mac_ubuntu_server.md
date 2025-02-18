---
layout: post
title:  "Rejuvenate Old Mac as Ubuntu Server"
date:   2025-02-09 21:58:52 +1100
published: false
toc: true
---

A 10 year old Mac Air runs perfectly. However with only X RAM and Y storage it lacks the specs to support modern MacOS operating system. This is more than sufficient for Ubuntu server with basic tasks of serving network drives and a few small web apps that we require to be always up.

**Summary**

1. Deauthorise services.
2. Download Ubuntu Server and create bootable disk
3. Install Ubuntu Server

2. Prevent sleep on lid closure.
3. Turn screen off.

## Procedure

### Sub heading 1

Text

[command block]


### Prevent sleeping

Next, disable laptop from entering suspend mode when lid is closed. See how to edit the login configuration to [prevent sleeping on lid closure]({% post_url 2025-02-09-stop_server_sleeping %}).

### Turn screen off

Finally, there is no need to have the laptop display on, as the machine is now always accessed from remote login. Follow how to [turn the screen off]({% post_url 2025-02-09-turn_screen_off %}) to disable the screen.


**References**

- [https://medium.com/@t.deb41/how-to-turn-your-old-macbook-into-a-home-server-2bb04a5277f7] - on how to setup as server
