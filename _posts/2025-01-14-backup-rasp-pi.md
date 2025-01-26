---
layout: post
title:  "How to backup raspberry pi"
date:   2025-01-14 20:35:23 +1100
published: false
toc: true
---

How to backup raspberry pi SD card to USB with rpi-clone.

**Summary**

We use a 16GB USB stick to ensure sufficient capacity to backup the 6GB SD card on the Raspberry Pi. This procedure uses the following commands to firstly clear and reformat a 16GB USB stick, and secondly backup the Raspberry Pi SD card to the USB stick.

Firstly, on macos:

1. [`diskutil rename`] - to rename our USB volume.
2. ['diskutil erasedisk`] to erase and reformat the USB volume.

Secondly, on Raspberry Pi:

3. [rpi-clone] - to backup SD card to image on destination device, in our case a USB.


## Procedure

### Find the name of SD card

On the Raspberry Pi, run fdisk to list devices and find the name of the SD card in our Pi, in our case `/dev/mmcblk0`.

`sudo fdisk -l`

Or we can use the disk utility `diskutil` to list the names of devices

`diskutil list`

```
/dev/disk8 (external, physical):
   #:                       TYPE NAME                    SIZE       IDENTIFIER
   0:     FDisk_partition_scheme                        *16.0 GB    disk8
   1:             Windows_FAT_32 TSB USB DRV             16.0 GB    disk8s1
```
This shows that the usb name has disk name `TSB USB DRV` and disk identifier `disk8s1` and formatted as `Windows_FAT_32`. The path of the usb is `/Volumes/TSB\ USB\ DRV`


### Format usb

EXT4 is the preferred file format for linux usbs.

The macos diskutil utility only formats to ExFAT. Use brew to install e2fsprogs which provides the mke2fs tool to reformat to ext4.

First rename the disk to a useful name `PiBackup`, to hint its contents. Running `ls /Volumes` or `diskutil list` confirms the volume is renamed.

`sudo diskutil rename TSB\ USB\ DRV PiBackup`


Unmount the disk before formatting

`diskutil unmountDisk disk8s1`
`sudo /opt/homebrew/opt/e2fsprogs/sbin/mke2fs -t ext4 /dev/disk8s2`

```
mke2fs 1.47.1 (20-May-2024)
/dev/disk8s2 contains a vfat file system labelled 'PIBACKUP'
Proceed anyway? (y,N) y
Creating filesystem with 3864064 4k blocks and 966656 inodes
Filesystem UUID: e967cbcb-7ff3-4919-a42c-c7ecb2058f44
Superblock backups stored on blocks:
	32768, 98304, 163840, 229376, 294912, 819200, 884736, 1605632, 2654208

Allocating group tables: done
Writing inode tables: done
Creating journal (16384 blocks):
done
Writing superblocks and filesystem accounting information: done
```
Note after doing this, the usb was not mountable on macos laptop. Hence reformatted the usb to exFAT.

Used `diskutil` to format to the similar `exFAT` format and rename the disk to "PiBackup" in a single command.

`sudo diskutil erasedisk exFAT PiBackup disk8`

```
Password:
Started erase on disk8
Unmounting disk
Creating the partition map
Waiting for partitions to activate
Formatting disk8s2 as ExFAT with name PiBackup
Volume name      : PiBackup
Partition offset : 411648 sectors (210763776 bytes)
Volume size      : 30912512 sectors (15827206144 bytes)
Bytes per sector : 512
Bytes per cluster: 32768
FAT offset       : 2048 sectors (1048576 bytes)
# FAT sectors    : 4096
Number of FATs   : 1
Cluster offset   : 6144 sectors (3145728 bytes)
# Clusters       : 482912
Volume Serial #  : 678645f1
Bitmap start     : 2
Bitmap file size : 60364
Upcase start     : 4
Upcase file size : 5836
Root start       : 5
Mounting disk
Finished erase on disk8
```

However, on plugging the usb into the Raspberry PI, it refused to mount with error "unknown filesystem type 'exfat'". Hence we will revert back to erasing the disk and keeping filesystem type FAT32.

Back on macos, reformatted to FAT32:

```
sudo diskutil erasedisk FAT32 PiBackup disk8
Password:
Started erase on disk8
Unmounting disk
Creating the partition map
Waiting for partitions to activate
Formatting disk8s2 as MS-DOS (FAT32) with name PiBackup
512 bytes per physical sector
/dev/rdisk8s2: 30882320 sectors in 1930145 FAT32 clusters (8192 bytes/cluster)
bps=512 spc=16 res=32 nft=2 mid=0xf8 spt=32 hds=255 hid=411648 drv=0x80 bsec=30912512 bspf=15080 rdcl=2 infs=1 bkbs=6
Mounting disk
Finished erase on disk8
```

Success, usb mounts successfully at `/media/pi/PIBACKUP` in Raspberry Pi

### Create backup

We use the `dd` file copy utility to create an backup image of the SD disk and write it to a usb stick.


First, plug in the usb stick to mount it. Open `File manager` shows us the path of the memory stick is `/media/pi/PIBACKUP`.

Second, check names and mountpoints with `lsblk`

`lsblk`

shows SD card is device name `/dev/mmcblk0` and usb mount point is `/media/pi/PIBACKUP` and device name `/dev/sdb2`. Now we write a copy of the SD card to file `pi_img.img` on the USB drive with:

`sudo dd if=/dev/mmcblk0 of=media/pi/PIBACKUP/pi_img.img bs=1M`

However, this failed with an error file too large, despite usb disk being 16GB and Pi SD disk being only 6GB.

Instead, we tried `rpi-clone` utility for backing up a Raspberry Pi which is a wrapper for `dd` that performs a range of checks. We run this in verbose mode.

`sudo rpi-clone sdb -v`

This warns that all data will be overwritten on the drive mounted to device /dev/sdb. Respond "yes" to confirm overwrite.

Clone completed successfully after 15 minutes!

**References**

[https://github.com/billw2/rpi-clone]

[https://linuxconfig.org/how-to-backup-raspberry-pi]
