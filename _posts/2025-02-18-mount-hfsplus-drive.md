---
layout: note
title:  "Mount external drives for writing MacOS files"
date:   2025-02-18 19:28:33 +1100
published: true
toc: true
---

External drives formatted in Apple filesystems can be mounted in read write mode on Ubuntu Server OS, providing the drive is formatted in Apple HFS/HFS+ format. As of Jan 2025, there is very limited support for mounting Apple APFS formatted drives on Ubuntu, and they can only be mounted in read mode (using <https://github.com/sgan81/apfs-fuse> library)

**Summary**

1. `apt-get install hfsprogs` - Install `hfsprogs` package required to read-write to drives with file format HFS/HFS+
2. `sudo fdisk -l` - fetch device block name and file type of externam drive.
3. `mkdir -p /media/[mount_name]` - create mount point.
4. `sudo mount -v -t hfsplus -o force,rw,uid=1000,gid=1000 [device_vol_name] /media/[mount_name]`- mount the device volume at mount point.
5. `sudo blkid [device_vol_name] | awk -F'"' '{print $2}'` - fetch device volume block id to use in `/etc/fstab`.
6. `sed -i '\$a '"UUID=[device_block_id] /media/[mount_name] hfsplus nosuid,nodev,nofail,force,rw,uid=1000,gid=1000 0 0" /etc/fstab` - add device volume mounting to `/etc/fstab`.

## Procedure

### Install hfsprogs

Package `hfsprogs` is required to force rw mounting of HFS+ file systems.

```bash
apt-get update
apt-get install hfsprogs
```

### Identify device volume

First, fetch the volume block details of the external drive. We do this by searching for Apple type devices excluding Apple boot devices.

```bash
sudo fdisk -l | grep Apple | grep -iv 'Apple boot'
```

If you have multiple Apple formatted external drives, identify the drive  volume of interest from volume size. In our case we see that the drive size is 1.8T, and use that to fetch the volume name, which is the first argument returned.

```bash
DRV_SIZE=1.8T
BLK="$(sudo fdisk -l | grep Apple | grep -iv 'Apple boot' | grep $DRV_SIZE)"
BLK_NAME="$(echo ${BLK} | awk '{print $1}')"
```

`fdisk -l` also shows that the volume is type "Apple HFS/HFS+" which we can mount as type "hfsplus". If the drive is Apple APFS format, it cannot be mounted read write on Ubuntu, and will need to be erased and reformatted as Apple HFS/HFS+ format using Disk Utility app or `diskutil` on MacOS machine.

### Mount HFS

Next, create the directory that will be the mount point. On Ubuntu Server, external drives are mounted in /media. To associate the mount directory with the drive, we append the drive size to the drive name(replacing full stops with underscores).

```bash
DRV_NAME=seagate1-${DRV_SIZE//./_}
mkdir -p /media/${DRV_NAME}
```

Mount the device volume using `-v` for verbose, and `force, rw` to force mounting in read-write mode. User and Group permissions of the mount directory should be set to `uid=1000,gid=1000` to set the primary account holder as user and group owner. The file system type is `hfsplus`.

```bash
sudo mount -v -t hfsplus -o force,rw,uid=1000,gid=1000 ${BLK_NAME} /media/${DRV_NAME}
```

Confirm the drive is mounted with `mount -l` or `ls -l /media`

```bash
mount -l |grep -i ${DRV_NAME}
ls -l /media
```

### Add drive to /etc/fstab

The mount rule needs to be added to `/etc/fstab` in order to mount the drive on reboot. The fstab file uses the block id to identify the device volume which we fetch with `blkid` which returns the block id as the second argument.

```bash
BLK_ID="$(sudo blkid ${BLK_NAME} | awk -F'"' '{print $2}')"
FSTAB_RULE="UUID=${BLK_ID} /media/${DRV_NAME} hfsplus nosuid,nodev,nofail,force,rw,uid=1000,gid=1000 0 0"
sed -i '\$a '"${FSTAB_RULE}" /etc/fstab
```

Confirm the drive is added with:

```bash
cat /etc/fstab
```

Note: the drive does not automount when plugged into Ubuntu Server machine. The user needs to run `mount ....` to mount it.

## Troubleshooting

The drive may mount as readonly (`ro`), despite options `force, rw` in the mount command. This is detected as:

```bash
mount -l |grep /media
/dev/sdb2 on /media/seagate1-1_8T type hfsplus (ro,relatime,umask=22,uid=1000,gid=1000,nls=utf8)
```

Review `dmesg`:

```bash
sudo dmesg | grep hfsplus | more
hfsplus: Filesystem was not cleanly unmounted, running fsck.hfsplus is recommended.  mounti
ng read-only.
```

Running `fsck.hfsplus` on the drive fixed the issue, after which re-running mount  correctly mounted the drive in `rw` mode.

```bash
sudo fsck.hfsplus /dev/sdb2
```

Then unmount and remount disk. If not unmounting, ensure the mount point is not in use, navigate elsewhere, then use lazy unmount and forced umount if necessaary. If unmounted and still failing to umount due to 'already mounted or mount point busy' error, then `reboot` can be the easiest option to remount the disk.

```bash
cd
sudo umount -l /dev/sdb2
sudo umount -f /dev/sdb2
```
