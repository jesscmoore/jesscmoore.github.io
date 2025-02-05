---
layout: post
title:  "Changing to unencrypted backups in Time Machine"
date:   2025-02-03 09:39:44 +1100
published: false
toc: true
---

Time Machine retains the settings of a backup disk which can be problematic. If one has previously backed up in encrypted mode, it is not possible to switch back to unencrypted back up mode, without erasing the volume.

## Summary


1. [Disk Utility > Erase Volume] - deleting volumes makes space for new unencrypted volume creation by Time Machine.
2. [Disk Utility > Erase Disk] - erases and reformats the disk allowing switch to a different file format

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
