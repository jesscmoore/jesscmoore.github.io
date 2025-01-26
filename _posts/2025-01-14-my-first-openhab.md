---
layout: post
title:  "My first Openhab test"
date:   2025-01-14 11:29:07 +1100
published: false
toc: true
---

How to start using [openHAB](https://www.openhab.org/docs/) library for connection and control of wifi connected devices in the home.

**Summary**
1. [ifconfig] - to find RPI MAC address
2. [diskutil] - to rename, erase and format a micro SD card to prepare for write of Openhabian image.
3. `Raspberry Pi Imager` - write the Openhabian image (incl. Raspberry Pi OS) to micro SD card

**Requires**

Hardware:

- `Raspberry Pi` - Raspberry Pi 4 recommmended. However a Pi 2 or 3 is fine with 2 GB RAM and a 16 GB SD card.
- `Raspberry Pi Official Power Supply` - RPI 3 requires 5V 2.2A supply. Typically USB A to microUSB provides only 5V 1A or 2A, both of which cause low voltage issues.
- `Micro SD card (Endurance)` - Endurance type recommended for better read write longevity. Minimum 16GB.

Optional (required for SD mirroring for better reliability and backups):

- `2nd Micro SD card (Endurance)` - Two cards required in order to use the recommended SD mirroring feature to provide a backup. THis is especially recommended if running with low RAM (we only have 1GB RAM on the RPI 3). Must have minimum size at least equal or greater than 1st SD card.
- `Micro SD card reader with USB A` - to plug the 2nd micro SD card into the RPI USB A slot.

Software:

- [Openhabian](https://www.openhab.org/docs/installation/openhabian.html) - Openhabian image (including RPI OS) is recommended for best openhab experience on Raspberry Pi use Raspberry Pi 4 or 5 with 2 or 4 GB RAM running Raspberry PI OS 64-bit Bookworm.
- [diskutil] - to rename and format SD card
- `Raspberry Pi Imager` - write the Openhabian image (incl. Raspberry Pi OS) to micro SD card


Both the Raspberry PI OS 64-bit Bookworm (1.2GB) and Raspberry Pi OS 64-bit Lite Bookworm (430MB) contain the required OpenJDK 17. We [updated the OS to the full Bookworm]({% post_url 2025-01-15-update-rasp-pi %}) and can revert to the Lite if necessary.

[custom docker storage location]({% post_url 2023-11-10-move-docker-install %})

From https://www.openhab.org/docs/:

Please be aware of two potential limitations of Raspberry Pis: RPi 3 and older are limited in RAM (1 GB of memory or less) and will probably not perform well when additional memory hungry applications such as databases and data visualization programs are being used. You will want to have two GB for that to work smoothly. Running Raspberries off the internal SD card only may result in system instabilities as these memory cards can degrade quickly under openHAB's use conditions (infamous 'wearout').

We will likely find ourselves testing this issue on our older Pi.

## Procedure

### Configured modem to assign RPI IP address based on mac address

OpenHabian recommends that the RPI is configured on our modem to always receive the same IP address.

1. Open the modem admin webpage at http://10.1.1.1 on our main laptop. Alternatively it can be done from browser on the RPI. Select the [Local Network] card, and clicked [Add new static lease]
2. Enter the following details

```
hostname: [RPI hostname]
MAC address: [RPI MAC address]
IP: [choose an IP with format 10.1.1.X]
```

where the hostname is that assigned during the RPI Imager customisation, and the MAC address is found by ssh-ing to the RPI so it can be copied and pasted into the modem admin webpage.

```
ssh [username]@[hostname.local]
ifconfig
...
global>
        ether b8:27:eb:cd:d9:08  txqueuelen 1000  (Ethernet)
...
```
The above line shows the MAC address. Entering the MAC address of the RPI will pop up the RPI device, select this device.

You can choose any IP address that is not already in use.
Then click [+] button to add this static DHCP lease.

Disconnect and reconnect to wifi on the RPI confirms we are now using the specified static DHCP lease.

`ifconfig wlan0`

### Openhab install

**Openhab or Openhabian**

It is recommended to install [Openhabian](https://github.com/openhab/openhabian) on RPIs, as it is a prepackaged image containing Raspberry PI OS Lite and OpenHab. They suggest using the Raspberry Pi Imager to burn Openhabian onto a new micro SD card.

The Openhabian Raspberry Pi OS is a headless RPI Lite install where RPI access is via terminal only and does not have the Raspberry windows desktop.

**64-bit or 32-bit**

Openhabian github page advises to choose the 64-bit version of OpenHabian, however notes both 32-bit and 64-bit versions will work and that the 64-bit version is more memory hungry. From https://github.com/openhab/openhabian:

```
RPi 3 and newer have a 64 bit processor. There's openHABian images available in both, 32 and 64 bit. Choose yours based on your hardware and primary use case. Please be aware that you cannot change once you decided in favor of either 32 or 64 bit. Should you need to revoke your choice, export/backup your config and install a fresh system, then import your config there.

Use the 64 bit image versions but please be aware that 64 bit always has one major drawback: increased memory usage. That is not a good idea on heavily memory constrained platforms like Raspberries. If you want to go with 64 bit, ensure your RPi has a minimum of 2 GB, 4 will put you on the safe side. You can use the 32 bit version for older or non official addons that will not work on 64 bit yet. Note there's a known issue on 32 bit, JS rules are reported to be annoyingly slow on first startup and in some Blockly use cases. If you consider using the (newer but still experimental) Java version 21, if possible choose 64 bit.
```

#### Format the SD card

Before writing the Openhabian image it is good practise to format the SD. We use an existing 32GB micro SD card. After copying the existing files to backup, we find the device name of the SD is `disk6` and rename the card to `OpenHabian`during the reformat to FAT32.

```
diskutil list
...
/dev/disk6 (external, physical):
   #:                       TYPE NAME                    SIZE       IDENTIFIER
   0:     FDisk_partition_scheme                        *31.9 GB    disk6
   1:             Windows_FAT_32 NO NAME                 31.9 GB    disk6s1
```


```
sudo diskutil erasedisk FAT32 OpenHabian disk6
Password:
Started erase on disk6
Unmounting disk
Creating the partition map
Waiting for partitions to activate
Formatting disk6s2 as MS-DOS (FAT32) with name OpenHabian
512 bytes per physical sector
/dev/rdisk6s2: 61891008 sectors in 1934094 FAT32 clusters (16384 bytes/cluster)
bps=512 spc=32 res=32 nft=2 mid=0xf8 spt=32 hds=255 hid=411648 drv=0x80 bsec=61921280 bspf=15111 rdcl=2 infs=1 bkbs=6
Mounting disk
Finished erase on disk6
```

Inspecting the SD shows the reformatted volume is now renamed with almost the full 32GB available
```
diskutil list
...
/dev/disk6 (external, physical):
   #:                       TYPE NAME                    SIZE       IDENTIFIER
   0:      GUID_partition_scheme                        *31.9 GB    disk6
   1:                        EFI EFI                     209.7 MB   disk6s1
   2:       Microsoft Basic Data OPENHABIAN              31.7 GB    disk6s2
```


Opening RP Imager app on MacOS, selecting `Other Specific Purpose OS` and `Home Assistants and Home Automation`, then `OpenHAB`, we find that only the 32-bit version is listed in the RPI Imager. We choose to try this 32-bit version: select `openHabian (32-bit)` which was released on 2024-12-18.

Alternatively, we could have downloaded the latest stable Openhabian 64-bit from https://github.com/openhab/openhabian/releases and selected this image file on our MacOS in Imager to burn to SD.

#### Write Openhabian image to SD

In RP Imager app, we set the RPI device type, storage location to burn to, and operating system to write.  Under Operating System we first selected `Other Specific Purpose OS > Home Assistants and Home Automation > OpenHAB`. As no 64-bit OS version is listed in RPI Imager, we accessed the latest stable releases from [openhabian on github](https://github.com/openhab/openhabian/releases) which has both 32-bit and 64-bit. After considering the README advice, we chose the 32-bit version (`openhabian-raspios32-latest-202412180636-crcdd67c747.img.xz`) to reduce memory use, noting it may affect some OpenHab functionality such as JS rules.

```
Raspberry PI device: Raspberry Pi 3
Operating System: Custom > selected downloaded openhabian img.xz file
Storage: selected micro SD card (mounted as /Volumes/OpenHabian)
```

Then selected `RPI OS Customisation`, and made these settings:

```
hostname: raspberrypi.local
username: jmoore
password: [your password]
SSID: [your SSID]
SSID password: [your SSID password]
Wireless LAN country: AU
Set locale settings: Australia/Sydney
Keyboard layout: au
Enable SSH: true
Allow public-key authentication only
```

Confirmed we wished to erase all data on the SD card in order to burn bootable OS image. It takes several minutes to write the image.


### Boot openhabian

Connect **RPI via ethernet to modem** to ensure initial connection to internet

Insert openhabian micro SD into RPI micro SD socket.

Plug RPI into power to power up and begin booting new OS.

After ~5 minutes, if successful, you will be able to ssh to the machine and see the machine in the list of connected devices in your modem admin webpage.

```
ssh jmoore@raspberrypi
tail /boot/first-boot.log
```

This will show the boot logfile, if any issues.

On first boot of a new Openhabian RPI OS, the RPI will automatically run the `openhabian-conf` with default values, if not run by the user. Note, this may revert hostname, timezone, locale and setup openhab admin account with default values.

### Configure Openhabian PI OS

The openhabian documentation https://www.openhab.org/docs/installation/openhabian.html#more-openhabian-configuration shows us we can configure timezone/locale and accounts in the openhabian-config.

We use `openhabian-config` rather than `raspi-config` to set locale, timezone, hostname as openhabian-config must be run anyway to set those and other values. As `openhabian-config` will run automatically after first boot if not done by the user, and it will apply default values, it is better to run this straight away and get it done to avoid having to redo it.

```
ssh jmoore@raspberrypi
sudo openhabian-config
```


Use `Enter` to execute, `Space` to select and `Tab` to jump to the actions on the bottom of the screen. Press `Esc twice` to exit the configuration tool.


#### Upgrade System

Ran `Upgrade System` to upgrade all packages on the system (including openhab) to latest stable release.


#### Upgrade Locale to set locale

Click `System Settings` > `Set system locale` > selected `en_AU.UTF-8`

Then executed config tool to exit and reboot, as reboot required after locale change.

#### Upgrade Timezone to set timezone

Click `System Settings` > `Set system timezone` > `Australia` > `Canberra` to set to local time.

#### Change hostname

The terminal still reads the hostname as `openhabian`. Change this to `raspberrypi` to be consistent.

Click `System Settings` > `Change hostname` > entered `raspberrypi`.

`Tab` to exit the openhabian-config menu.

#### Apply strong passwords to RPI user account and

Got into System Settings, Change passwords, to change passwords for the two accounts (jmoore on RPI, and openhab accounts). Ensuring that both have strong passwords generated with `openssl` or similar.


#### Apply changes

Exit menu. May need to Execute before Exit.

Rebooted to apply system changes

`sudo reboot`

Changes confirmed by successful ssh to RPI following reboot, and getting correct hostname and local time.

```
ssh jmoore@raspberrypi
...
Last login: Wed Jan 15 16:27:04 2025 from 10.1.1.195
jmoore@raspberrypi:~ $
```

Openhab web app can now be accessed from a browser at http://raspberrypi:8080 or http://10.1.1.55:8080


### Run Openhab Setup Wizard

Open `http://raspberrypi:8080 and create the openhab admin account

```
login: openhab
passwd: [your strong password]

Set location via map and added altitude 575m for Canberra

Set language English, region Australia and timezone Australia/Sydney

Selected add-on bindings, choosing the pre-selected defaults.
```

The Setup Wizard completes with the user logged in as the openhab admin account. A user does not have to be logged in to access openhab UI, however non admin users will not see the Settings and other functions for admin users.

### Set measurement system to metric

Click `Settings` > `Regional Settings` > `Show Advanced` > and select `Metric` and click `Save`.


### Set weekend days and holidays

Click `Settings` > `Ephemeris` and set

```
Weekend Days: Saturday, Sunday
Country: Australia
Region: Australian Capital Territory
```

Click `Save

### Add http binding

The http binding is needed to connect to a ESP8266 connected sensor, see https://github.com/gonium/esp8266-dht22-sensor/blob/master/README.md

Click `Add On Store` > `Bindings` > enter http and click `Install` to add this binding.

This also revealed our printer as a discoverable Thing.



## Troubleshooting

### RPI fails to boot with green light flashing

This most commonly indicates insufficient power supply. Fixed by replacing with USB C plug providing 5V 2.2A connected to USB A hub into which micro USB cable used. Most microUSB power supplies provide only 5V 0.5-2A which is insufficient for stable running of the RPIv3. Replacement with the official Raspberry Pi 3 power supply (5V 2.5A 12.5W) resolved the problem.

### Boot fails running Network Manager.

Login to your modem and check that the MAC address and hostname matches that set up for static DHCP lease, and that the SSID and wifi password match that of your modem.

It may fail to connect to wifi if it did not apply the OS Customisation steps set in the RPI Imager and if not connected to modem with ethernet cable for first boot.

These can be corrected on the RPI by running `sudo raspi-config`.

```
ssh jmoore@raspberrypi
sudo raspi-config
sudo reboot
```

Commands for `raspi-config` menu:

Use `Enter` to execute, `Space` to select and `Tab` to jump to the actions on the bottom of the screen. Press `Esc twice` to exit the configuration tool.


Successful connection to IP with static DHCP lease.


However, ssh to machine is now showing `openhabian login:`, paused here, then proceeded to startin installing basic cant be wrong passages, with log entry in european time zone.

Waited 1hr. Ssh-ing to RPI and reviewing first-boot.log shows install has been successful.

```
ssh [username]@raspberrypi
tail /boot/first-boot.log
2025-01-15_04:46:01_CET [openHABian] Beginning Mail Transfer Agent setup... SKIPPED (no configuration provided)
2025-01-15_04:46:01_CET [openHABian] Beginning Network UPS Tools setup... SKIPPED (no configuration provided)
2025-01-15_04:46:01_CET [openHABian] Applying file permissions recommendations... OK
2025-01-15_04:46:08_CET [openHABian] Setting up automated SD mirroring and backup... SKIPPED (no configuration provided)
2025-01-15_04:46:08_CET [openHABian] Cleaning up... OK
2025-01-15_04:46:34_CET [openHABian] Execution of 'openhabian-config unattended' completed.
2025-01-15_04:46:34_CET [openHABian] First time setup successfully finished. Rebooting your system!
2025-01-15_04:46:34_CET [openHABian] After rebooting the openHAB dashboard will be available at: http://openhabian:8080
2025-01-15_04:46:34_CET [openHABian] After rebooting to gain access to a console, simply reconnect using ssh.
Removed "/etc/systemd/system/multi-user.target.wants/comitup.service".
```


#### Received warning of weak password.

If you get the following warning in /boot/first-boot.log:

```
2025-01-15_06:21:41_CET [openHABian] Checking for default openHABian username:password combination... FAILED
Please set a strong password by typing `passwd openhabian`
```

Generate more secure passwords for RPI account and OpenHAB account with `openssl` and updated them in the Openhabian configuration with `sudo openhabian-config`

`openssl rand -base64 6`

`sudo openhabian-config`

Commands for `raspi-config` menu:

Use `Enter` to execute, `Space` to select and `Tab` to jump to the actions on the bottom of the screen. Press `Esc twice` to exit the configuration tool.

Clicked `System settings` > `Change password` > selected `Linux system` > entered new strong password

```
2025-01-15_16:48:26_AEDT [openHABian] Changing password for Linux account "openhabian"... OK
```

We also create a strong password for remote console `openhab` account

Clicked `System settings` > `Change password` > selected `Remote console openhab account` > entered new strong password
```
2025-01-15_16:53:44_AEDT [openHABian] Changing password for openHAB console account "openhab"... OK
```

`Exit`

Exiting the openhabian-config menu will no longer gives the weak password warning.

```
2025-01-15_16:56:01_AEDT [openHABian] Checking for default openHABian username:password combination... OK
```

And reboot

`sudo reboot`

Confirmed password change by using `sudo` after reboot.


**References**


- [https://www.openhab.org/docs/installation/openhabian.html]
- [https://www.openhab.org/docs/]
- [https://community.openhab.org/t/openhabian-hassle-free-openhab-setup/13379]
