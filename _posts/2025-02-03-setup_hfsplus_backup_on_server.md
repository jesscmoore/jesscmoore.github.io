---
layout: post
title:  "Setup Macbook backups on Ubuntu Server"
date:   2025-02-03 09:39:44 +1100
published: false
toc: true
---

We backup a macbook using a Seagate HFS+ external drive mounted on Ubuntu server and made accessible as a network drive to other MacOS machines over lan using Samba and Avahi.

## Summary


1. [command] - 1 line explanation
2. [command] - 1 line explanation

## Procedure

MacOS filesystem format since approx 2017 has been APFS. TimeMachine will format a new external storage drive as APFS by default on recent Macs.

### Erased encrypted volumes on external drive

As this external drive had been first used by TimeMachine in encrypted APFS which cannot be mounted in read write mode in linux, I had to erase the encrypted volume.

Opened `Disk Utility` app > `View` > `Show All Devices`

This shows the volumes nested in the container on the Seagate One Touch usb drive. To erase the encrypted volumes, for each volume on the Seagate:

Click volume > click `Erase`

Remove unnecessary volume for 2nd machine backup.

Clicked 2nd volume > click `-` to erase the volume.

The drive is now empty except for some system files, and contains no encrypted content.


### Test APFS backup to test TimeMachine

First, need to forget the existing backup configuration for the drive.

Open `TimeMachine` > select `One Touch` drive > click `-` > `Forget Destination`

Now we can add the drive, and ensure we don't encrypt.

`Add Backup Disk` > select `One Touch` > ensure these settings:

```console
Encrypt Backup: off
Disk Usage Limit: None
```
and click `Done`. Time Machine will now perform the backup, expect it to take several hours.

#### Using same drive for HFS

An older mac using HFS can be backed up to the same storage device with TimeMachine by first creating a volume on the drive in the required format with Disk Utility app on MacOS.

Open `Disk Utility` > `View` > `Show All Devices` > click the container on the storage device > `Partition` > `+` > ensure you select the required file system type.

This way Time Machine on the older mac will find a usable storage destination.


### Backing up MAC to HFS storage drive over LAN

### Mount external drive

Refer to [mount HFS/HFS external drive]({% post_url 2025-02-18-mount-hfsplus-drive %}) for how to mount an Apple HFS/HFS+ external drive on Ubuntu Server.


### Configure Samba share for external drive

Refer to [setup Samba share]({% post_url 2025-02-18-samba-share-timemachine %}) to read how to configure Samba share accessible by TimeMachine for the external drive.




<!-- ### Setup Avahi service for share

Create an avahi service for the samba share where the name of the `txt-record` must match the name of the samba share.

The avahi daemon will broadcast the share to make it recognisable as a network drive to Apple devices. The 3rd service statement announces this share drive.

Add the text below to the avahi daemon config file:

```bash
sudo vim /etc/avahi/services/samba.service
```

```xml
<?xml version="1.0" standalone='no'?><!--*-nxml-*-->
<!DOCTYPE service-group SYSTEM "avahi-service.dtd">
<service-group>
  <name replace-wildcards="yes">%h</name>
  <service>
    <type>_smb._tcp</type>
    <port>445</port>
  </service>
  <service>
    <type>_device-info._tcp</type>
    <port>9</port>
    <txt-record>model=TimeCapsule8,119</txt-record>
  </service>
  <service>
    <type>_adisk._tcp</type>
    <port>9</port>
    <txt-record>dk0=adVN=backups-seagate-HFS,adVF=0x82</txt-record>
    <txt-record>sys=adVF=0x100</txt-record>
  </service>
</service-group>sudo nano /etc/avahi/services/samba.service
``` -->


### Allow ports in firewall

Allow the ports required by samba and restart ufw.

```bash
sudo ufw allow samba
sudo ufw --force enable
```

### On macOS setup TimeMachine

After mounting HFS drive, configuring share in Samba and service in Avahi

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

#### Configure weekly backups

In Time Machine, with desired disk selected,

Click `Options` > `Backup Frequency`: select desired frequency

and click `Done`.

The Apple Time Machine documentation recommends Samba over Netatalk/AFP. However if backup over Samba is overly slow, we could try Netatalk.


### Useful commands

- [id] - show user's username and groups with uid and gids
- [lsblk] - list block devices
- `sudo blkid /dev/sdc2` - show the block id of device
- `fdisk -l` - list disks
- `mount -l` - list mounted devices
- `sudo testparm -s` - test samba configuration
- `systemctl status smbd` - show samba service status
- `systemctl restart smbd` - restart samba service


**References**

- [https://blog.jhnr.ch/2023/01/09/setup-apple-time-machine-network-drive-with-samba-on-ubuntu-22.04/]
- [https://www.vanwerkhoven.org/blog/2021/timemachine-to-linux-server/]
- [https://wiki.samba.org/index.php/FAQ#I_cannot_connect_as_a_user_from_another_machine]
