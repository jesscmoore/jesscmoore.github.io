---
layout: post
title:  "How to update Raspberry Pi OS"
date:   2025-01-15 00:24:28 +1100
published: no
toc: true
---

How to flash an updated Raspberry Pi OS to the SD card.

**Summary**

1. [Raspberry Pi Imager for MacOS] - used to download the current OS and write to image on micro SD card


## Requires

Hardware:

- 2nd micro SD card with recommended 16GB capacity (minimum 8GB).

Software:

- [Raspberry Pi Imager for MacOS] - used to download the current OS and write to image on micro SD card

## Procedure

### Write OS image to SD card

We use the Raspberry Pi Imager tool on https://www.raspberrypi.com/software/ to select the Raspberry OS and USB destination for download and configure the download.

Firstly, install a micro SD card into a SD reader in your laptop. We use a spare 64GB micro SD card that has been reformatted.

Secondly, download the Raspberry Pi Imager for MacOS and run the Imager.

We selected the Raspberry Pi OS 64-bit Bookworm (full 1.2GB install) to try the full install.

During the OS Customisation step, we want to configure for SSH access with public keys. Navigate to the Services tab and tick the Enable SSH checkbox.

Select the Allow public-key authentication only radio button. If you already have an SSH public key stored in ~/.ssh/id_rsa.pub, Imager automatically uses that public key to prefill the text box.

We also set a username, password and hostname raspberrypi.local.

Some additional settings such as connecting to wifi can be down with `sudo raspi-config` from the raspberry Pi after it is up and running.

### Insert the new SD card

Power off the Pi and remove the existing micro SD card and insert the new micro SD card with the new OS release. The micro SD card is located on the underside of the Raspberry Pi board and can be pulled out from underneath the touch screen display ribbon.

### Reboot

Power on to boot up the new OS release.

`cat /etc/os-release`

shows we are now running "Debian GNU/Linux 12 (bookworm)".

Checking disk usage finds 4.7G used of 64GB new SD card.

`df -h`

A low voltage warning in the status bar warns to check power supply. There is also a noticable lag.

```
vcgencmd get_throttled
throttled=0x50005
```

reveals that undervoltage detected and currently throttled. Purchasing the Raspberry Pi 5V 2.5A 12.5W Power Supply (for Raspberry 3 B) should provide the necessary stable power supply at the correct specification.


### Network

Click the network icon in status menu to connect to wifi.


### SSH

We can connect to the machine remotely with:

`ssh [username]@[hostname].local`

where the username and hostname were set in the customisation stage of the creating the OS image with Raspberry Pi Imager.

### Update packages

`sudo apt update`

Run the following command to upgrade all your installed packages to their latest versions:

`sudo apt full-upgrade`

Remove no longer required downloaded package files (.deb) with

`sudo apt clean`

Reboot

`sudo reboot`



**References**


- [https://www.raspberrypi.com/documentation/computers/os.html#upgrade-your-operating-system-to-a-new-major-version]
