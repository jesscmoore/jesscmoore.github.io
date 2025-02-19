---
layout: post
title:  "Setup Samba share for external drive"
date:   2025-02-18 23:57:42 +1100
published: true
toc: true
---

An external drive on Ubuntu Server can be made accessible to other machines by mounting as a Samba share drive. In this case we add the drive as a TimeMachine accessible Samba share.

**Summary**

1. `echo -e "[my_pwd]\n[my_pwd]\n" | sudo smbpasswd -a [my_user]` - Add Samba user
2. `sudo vim /etc/samba/smb.conf` - Edit Samba configuration to add Timemachine readable share for external drive.
3. `service smbd restart` - Restart Samba service.
4. `fw allow samba` - Open Samba ports in firewall.
5. `ufw --force enable` - Restart firewall.


## Procedure

### Add Samba user

Add the user owning /media/[drive] as a samba user.

```bash
echo -e "[my_pwd]\n[my_pwd]\n" | smbpasswd -a [my_user]
```


### Add share to Samba conf

```bash
DRV_SIZE=1.8T
DRV_NAME=seagate1-${DRV_SIZE//./_}
cat >> /etc/samba/smb.conf <<'EEOF'

[${DRV_NAME}]
    comment = Backups (${DRV_NAME})
    path = /media/${DRV_NAME}
    valid users = [my_user]
    read only = no
    vfs objects = catia fruit streams_xattr
    fruit:time machine = yes
EEOF
```

Confirm samba configuration with:
```bash
tail /etc/samba/smb.conf
```


Now restart Samba daemon

```bash
service smbd restart
```

### Update firewall

Open ports for Samba in firewall.

```bash
ufw allow samba
ufw --force enable
```


**References**

- [https://dev.to/ea2305/time-machine-backup-with-your-home-server-1lj6](https://dev.to/ea2305/time-machine-backup-with-your-home-server-1lj6)
- [https://blog.jhnr.ch/2023/01/09/setup-apple-time-machine-network-drive-with-samba-on-ubuntu-22.04/](https://blog.jhnr.ch/2023/01/09/setup-apple-time-machine-network-drive-with-samba-on-ubuntu-22.04/)
