---
layout: post
title:  "How to allocate a logical volume on Ubuntu"
date:   2023-11-10 13:23:03 +1100
categories: ubuntu
published: true
toc: true
---

**Summary**

If there is unallocated space on your disk, the safest option is to create a new logical volume, format the new volume, mount it and add to `/etc/fstab` and reboot.

1. Determine new volume size after reviewing existing logical volumes and disk usage
```
lsblk
df -Th
```

2. Create new logical volume named `volume_name` with a specified `size` on a paritcular device.
```
lvcreate -n [volume_name] -L [size] /dev/[device_name]
```

3. Format the file system of the new volume as ext4
```
mkfs.ext4 [device_name]/[volume_name]
```


4. Create mount point directory and mount logical volume to this location in a folder of `/opt` or another location.
```
mkdir /opt/[mount_sub_dir]
mount /dev/mapper/[device_name]-[volume_name] /opt/[mount_sub_dir]
```


5. Identify the block device UUID of the mount point by listing block device ids.
```
blkid
```

6. Edit `/etc/fstab` to ensure
```
echo "UUID=[uuid_string] /opt/[mount_sub_dir] ext4 defaults 0  1" >> /etc/fstab
```

7. Confirm mount points and new volume details with these commands
```
mount |grep /dev/
lsblk
fdisk -l
```


8. Reboot
```
reboot
```

Alternatively, if yo want to resize an existing logical volume, you will need to first identify and stop serviecs running on that volume
```
lsof |grep [mount_point]
systemctl stop [service]
```


## Procedure

### Review disk allocations and use

Inspect the disk allocation by listing block devices on the server. This shows the disk is 125G, however only 16G has been mounted as / and a further 16G as /var.

```
$ sudo lsblk -a
NAME        MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
loop0         7:0    0        0 loop
loop1         7:1    0        0 loop
loop2         7:2    0        0 loop
loop3         7:3    0        0 loop
loop4         7:4    0        0 loop
loop5         7:5    0        0 loop
loop6         7:6    0        0 loop
loop7         7:7    0        0 loop
sda           8:0    0  125G  0 disk
├─sda1        8:1    0   16G  0 part /
└─sda2        8:2    0  109G  0 part
  └─vg0-var 253:0    0   16G  0 lvm  /var
sr0          11:0    1 1024M  0 rom
``````
This tells us that `/var` is mounted at `/dev/vg0`
```
$ ls /dev/vg0
var
```

And that only 32G of 125G is allocated, leaving 93G available.

Our disk usage shows 13G used in /var and 4G in /.

```
$ df -Th
Filesystem          Type      Size  Used Avail Use% Mounted on
udev                devtmpfs  1.9G     0  1.9G   0% /dev
tmpfs               tmpfs     394M  864K  393M   1% /run
/dev/sda1           ext4       16G  4.2G   11G  28% /
tmpfs               tmpfs     2.0G     0  2.0G   0% /dev/shm
tmpfs               tmpfs     5.0M     0  5.0M   0% /run/lock
tmpfs               tmpfs     2.0G     0  2.0G   0% /sys/fs/cgroup
/dev/mapper/vg0-var ext4       16G   13G  2.0G  87% /var
tmpfs               tmpfs     394M     0  394M   0% /run/user/1000
tmpfs               tmpfs     394M     0  394M   0% /run/user/1004
```

Docker requires substantial storage for build and other artifacts. Here we allocate dedicated space for docker. Here we see that many processes are running on `/var`, and many of those are `docker`

```
lsof |grep /var
```

Rather than resizing `/var` we can create `/opt/dash` for the dash app docker artifacts, and set docker to install to `/opt/dash`. Let's allocate 80G to /opt/dash

If desired stop services, here we stop docker and containerd

```
$ systemctl stop docker

Warning: Stopping docker.service, but it can still be activated by:
  docker.socket
$ systemctl stop containerd
```

### Create new logical volume

Create new logical volume with desired size, and confirm that it has been allocated 80G

```
$ lvcreate -n dash -L 80G /dev/vg0
  Logical volume "dash" created.
$ lsblk

NAME         MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda            8:0    0  125G  0 disk
├─sda1         8:1    0   16G  0 part /
└─sda2         8:2    0  109G  0 part
  ├─vg0-var  253:0    0   16G  0 lvm  /var
  └─vg0-dash 253:1    0   80G  0 lvm
sr0           11:0    1 1024M  0 rom
$ ls /dev/vg0
dash  var
```

Here we can see our volumnes
```
$ ll /dev/mapper

total 0
drwxr-xr-x  2 root root     100 Dec 20 15:55 ./
drwxr-xr-x 19 root root    4080 Dec 20 15:55 ../
crw-------  1 root root 10, 236 Jun 16  2023 control
lrwxrwxrwx  1 root root       7 Dec 20 15:55 vg0-dash -> ../dm-1
lrwxrwxrwx  1 root root       7 Jun 16  2023 vg0-var -> ../dm-0
```

```
$ fdisk -l

Disk /dev/sda: 125 GiB, 134217728000 bytes, 262144000 sectors
Disk model: Virtual disk
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: dos
Disk identifier: 0x73b45ee2

Device     Boot    Start       End   Sectors  Size Id Type
/dev/sda1           2048  33556479  33554432   16G 83 Linux
/dev/sda2       33556480 262143999 228587520  109G 8e Linux LVM


Disk /dev/mapper/vg0-var: 16 GiB, 17179869184 bytes, 33554432 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes


Disk /dev/mapper/vg0-dash: 80 GiB, 85899345920 bytes, 167772160 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
```

### Format filesystem of new logical volume

Format the new logical volume file system
```
$ mkfs.ext4 /dev/vg0/dash

mke2fs 1.45.5 (07-Jan-2020)
Creating filesystem with 20971520 4k blocks and 5242880 inodes
Filesystem UUID: 24c561cc-d076-4fdf-9fd7-ac554327c776
Superblock backups stored on blocks:
	32768, 98304, 163840, 229376, 294912, 819200, 884736, 1605632, 2654208,
	4096000, 7962624, 11239424, 20480000

Allocating group tables: done
Writing inode tables: done
Creating journal (131072 blocks): done
Writing superblocks and filesystem accounting information: done
```

### Mount the new logical volume

Let's check how existing volumes are mounted

```
 mount |grep /dev/
devpts on /dev/pts type devpts (rw,nosuid,noexec,relatime,gid=5,mode=620,ptmxmode=000)
/dev/sda1 on / type ext4 (rw,relatime)
tmpfs on /dev/shm type tmpfs (rw,nosuid,nodev)
mqueue on /dev/mqueue type mqueue (rw,nosuid,nodev,noexec,relatime)
hugetlbfs on /dev/hugepages type hugetlbfs (rw,relatime,pagesize=2M)
/dev/mapper/vg0-var on /var type ext4 (rw,relatime)
```

Let's mount the new volume `vg0-dash` to `/opt/dash` after first creating the mount point `/opt/dash`

```
$ mkdir /opt/dash

$ mount /dev/mapper/vg0-dash /opt/dash
```

We can use `mount` or `lsblk` to confirm mount points

```
$ mount |grep /dev/
devpts on /dev/pts type devpts (rw,nosuid,noexec,relatime,gid=5,mode=620,ptmxmode=000)
/dev/sda1 on / type ext4 (rw,relatime)
tmpfs on /dev/shm type tmpfs (rw,nosuid,nodev)
mqueue on /dev/mqueue type mqueue (rw,nosuid,nodev,noexec,relatime)
hugetlbfs on /dev/hugepages type hugetlbfs (rw,relatime,pagesize=2M)
/dev/mapper/vg0-var on /var type ext4 (rw,relatime)
/dev/mapper/vg0-dash on /opt/dash type ext4 (rw,relatime)
```

```
$ lsblk
NAME         MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda            8:0    0  125G  0 disk
├─sda1         8:1    0   16G  0 part /
└─sda2         8:2    0  109G  0 part
  ├─vg0-var  253:0    0   16G  0 lvm  /var
  └─vg0-dash 253:1    0   80G  0 lvm  /opt/dash
sr0           11:0    1 1024M  0 rom
```

### Add to file systems table to mount on boot

The safest way to mount a block device is using the `UUID`, which we get from `blkid`

```
$ blkid

/dev/sda1: UUID="410a171d-9170-4cd4-a532-51c3cbb616c2" TYPE="ext4" PARTUUID="73b45ee2-01"
/dev/sda2: UUID="16tN3w-9n7o-e58x-iole-Oxdz-Sbku-ZBXo9C" TYPE="LVM2_member" PARTUUID="73b45ee2-02"
/dev/mapper/vg0-var: UUID="cca2b24a-4c08-4dfa-826d-5aac4fb71e36" TYPE="ext4"
/dev/mapper/vg0-dash: UUID="24c561cc-d076-4fdf-9fd7-ac554327c776" TYPE="ext4"
```

Edit `/etc/fstab` to add a new line for `/opt/dash` with the `UUID`. It should look like

```
cat /etc/fstab
# UNCONFIGURED FSTAB FOR BASE SYSTEM
# /dev/sda1  /  ext4  defaults  0  0
UUID=410a171d-9170-4cd4-a532-51c3cbb616c2 /  ext4  defaults  0  0
UUID=cca2b24a-4c08-4dfa-826d-5aac4fb71e36 /var ext4 defaults 0  1
UUID=24c561cc-d076-4fdf-9fd7-ac554327c776 /opt/dash ext4 defaults 0  1
```

Now the machine is ready to reboot

```
reboot
```
