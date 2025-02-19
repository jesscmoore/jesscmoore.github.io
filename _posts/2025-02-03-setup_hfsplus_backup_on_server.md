---
layout: post
title:  "Backup Macbook to External Drive on Ubuntu Server"
date:   2025-02-03 09:39:44 +1100
published: true
toc: true
---

We backup a macbook using a Seagate HFS+ external drive mounted on Ubuntu server and made accessible as a network drive to other MacOS machines over lan using Samba and Avahi.

## Requires

On server:

- `samba`
- `avahi`

On client:

- `TimeMachine.app`


## Procedure


### Erase existing volumes on drive

The external drive had previously been used for TimeMachine encrypted backups using the TimeMachine default APFS filesystem format, which has been the standard Apple file system format since 2017. As APFS format cannot be read-write mounted on Ubuntu, the drive must be erased and reformated to HPFS format which TimeMachine can also use for backups.

Opened `Disk Utility` app > `View` > `Show All Devices`

This shows the volumes nested in the container on the Seagate One Touch usb drive. To erase the encrypted volumes, for each volume on the Seagate:

Click volume > click `Erase`

The drive is now empty except for some system files, and contains no encrypted content.

Open `Disk Utility` > `View` > `Show All Devices` > click the container on the storage device > `Partition` > `+` > select `HFS/HFS+` format.


### Mount drive

Refer to [mount HFS/HFS external drive]({% post_url 2025-02-18-mount-hfsplus-drive %}) for how to mount an Apple HFS/HFS+ external drive on Ubuntu Server.


### Configure drive as Samba share

Refer to [setup Samba share]({% post_url 2025-02-18-samba-share-timemachine %}) to read how to configure Samba share accessible by TimeMachine for the external drive.


<!-- ### Setup Avahi service for share

Create an avahi service for the samba share where the name of the `txt-record` must match the name of the samba share.

The avahi daemon will broadcast the share to make it recognisable as a network drive to Apple devices. The 3rd service statement announces this share drive.

Add the text below to the avahi daemon config file:

```bash
sudo vim /etc/avahi/services/samba.service
```
-->

### Add network drive to Mac client

On MacOS client, add the drive as a networked drive:

Open `Finder.app` > `Go` > `Connect to Server` enter:

```console
smb://[my_user]@[my_host]
```
and click `Connect`. Login as `Registered User` with username `my_user` and password, using the Samba user and password created on the Ubuntu server.

This will add the host to the list of Locations in the Finder sidebar.


### Setup TimeMachine on Mac client

On MacOS client, open TimeMachine to add the drive as a backup destination.

Open `Time Machine` > Click `+` to add a new backup destination > select `backups-seagate-HFS` > click `Set Up Disk` > enter

```console
Registered User: on
Name: my_user
Password: my_pwd
```

where `my_user` and `my_pwd` are the user on our networked host that has samba share access and their samba password.

In the backup options window for `backup-seagate-HFS - BUDMEISTER.local`, choose these settings. Ensure `Encrypt Backup` is **not** selected.

```console
Encrypt Backup: off
Disk Usage Limit: None
```

Backup then begins!

A full backup may take more than 12 hours over wifi. Although incremental backups should be less than several hours. To maximise backup speed:

- Connect the client to LAN via ethernet.
- Use 5GHz wifi if requiring wifi.
- Schedule backups frequently, which should reduce the size of the backup diff.
- Avoid schedule overlap with server upgrades which would halt the backup.

#### Configure weekly backups

Schedule backup frequency in Time Machine:

Select backup disk > Click `Options` > `Backup Frequency`: choose desired frequency

and click `Done`.

The Apple Time Machine documentation recommends Samba over Netatalk/AFP. However if backup over Samba is overly slow, we could try Netatalk.


### Useful commands

- `id` - Show user's username and groups with uid and gids.
- `lsblk` - List block devices
- `blkid [device_name]` - Show the block id of specific device.
- `fdisk -l` - List disks and volumes, including unmounted volumes.
- `mount -l` - List mounted volumes.
- `testparm -s` - Test samba configuration.
- `systemctl status smbd` - Show Samba service status.
- `systemctl restart smbd` - Restart Samba service.


**References**

- [https://blog.jhnr.ch/2023/01/09/setup-apple-time-machine-network-drive-with-samba-on-ubuntu-22.04/](https://blog.jhnr.ch/2023/01/09/setup-apple-time-machine-network-drive-with-samba-on-ubuntu-22.04/)
- [https://www.vanwerkhoven.org/blog/2021/timemachine-to-linux-server/](https://www.vanwerkhoven.org/blog/2021/timemachine-to-linux-server/)
- [https://dev.to/ea2305/time-machine-backup-with-your-home-server-1lj6](https://dev.to/ea2305/time-machine-backup-with-your-home-server-1lj6)
