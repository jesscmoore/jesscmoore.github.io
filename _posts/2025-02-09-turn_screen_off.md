---
layout: note
title:  "How to turn screen off"
date:   2025-02-09 21:57:25 +1100
published: false
toc: true
---

Create service to turn off screen after 1 sec of inactivity.


## Procedure

### Create screen blanking service

We create a custom service to blank the screen after 1 sec of inactivity.

```bash
sudo cat >> /etc/systemd/system/enable-console-blanking.service <<'EEOF'
[Unit]
Description=Enable virtual console blanking

[Service]
Type=oneshot
Environment=TERM=linux
StandardOutput=tty
TTYPath=/dev/console
ExecStart=/usr/bin/setterm -blank 1

[Install]
WantedBy=multi-user.target
EEOF
```

Set permissions and enable service.

```bash
sudo chmod 664 /etc/systemd/system/enable-console-blanking.service
sudo systemctl enable enable-console-blanking.service
```

Then apply changes with:

```bash
reboot
```
