---
layout: post
title:  "Ubuntu: how to connect to wifi with Broadcom Wireless Adaptor"
date:   2025-01-29 16:19:29 +1100
published: false
toc: true
---

Some Broadcom Wireless Adaptors require drivers that are not supported out of the box with the Ubuntu Server 24.04.1 LTS.

**Summary**

1. [lspci --n |grep Network] - list
2. [uname -nrm] - list kernerl version
3. [apt-cache search broadcom linux-headers] - search for broadcom and linux header packages
4. [sudo apt-get install linux-headers-6.11.0-14-generic broadcom-sta-dkms && sudo apt autoremove] - install required package for this wifi adaptor
5. [sudo modprobe -v -r b44 b43 b43legacy brcmsmac] - remove conflicting already installed broadcom modules
6. [sudo modprobe -v wl] - install required broadcom module
7. [netplan status --all] - identify wireless interface name
8. [sudo apt install nmcli wpa_supplicant] - install wpa_supplicant also required
9. [sudo vim /etc/netplan/00-installer-config.yaml] - configure wifi interface with SSID and other settings
10. [sudo netplan generate] - check and generate configuration in networkd
11. [sudo netplan apply] - apply configuration
12. [netplan status --all] - review
13. [sudo reboot] - restart


## Procedure

### Install wireless network adaptor driver

To fully identify the required driver package, we need the device name and numberic id of the network adaptor.

```
$ lspci -nn |grep Network
03:00.0 Network controller [0280]: Broadcom Inc. and subsidiaries BCM4360 802.11ac Dual Band Wireless Network Adapter [14e4:43a0] (rev 03)
```

The `4e4:43a0 rev 03` found in our Apple Mac Air 2013 requires some special steps.

This requires installing the source code for the driver and the linux headers to install it into our kernal version. `broadcom-sta-dkms` contains the dkms source for the Broadcom STA Wireless driver. We install `linux-headers-6.11.0-14-generic` as we're running `6.11.0-14-generic x86_64` kernel version.

```
$ uname -nrm
$ apt-cache search broadcom
$ apt-cache search linux-headers
$ sudo apt-get install linux-headers-6.11.0-14-generic broadcom-sta-dkms && sudo apt autoremove
```

Next, we run `modprobe` to remove conflicting broadcom driver modules, and then install the `wl` module provided in `broadcom-sta-dkms` package. It is recommended to use `-v` for verbose mode and do a dry-run first with `-n`.

```
sudo modprobe -v -r b44 b43 b43legacy brcmsmac
sudo modprobe -v wl
```

The wifi interface is now recognised. Using `--all` includes interfaces that are down in the listing. Alternatively use `ip a`. This shows the name of our wireless interface is `wlp3s0`.

```
netplan status --all
```

The package `wpa_supplicant` appears to also be needed to connect to the wifi interface. It comes as a dependency of `nmcli` package, which is the Network Manage CLI. As we're using Networkd instead of Network Manager, we shouldn't need nmcli. Listing the devices afterwards, shows ethernet and wifi devices are not managed by Network Manager.

<!-- TODO: repeat without `nmcli` -->

```
$ sudo apt install nmcli wpa_supplicant
$ sudo nmcli d
```

### Configure wifi network interface

Edit your netplan yaml file to configure the wifi interface with our access point credentials and other settings.

```
Configure wireless interface with netplan:
sudo vim /etc/netplan/00-installer-config.yaml

  wifis:
    wlp3s0:
      dhcp4: yes
      dhcp6: yes
      access-points:
        "your SSID":
          password: "your pw"
```

After applying the configuration, netplan will show wlp3s0 state UNKNOWN.

```
sudo netplan generate
sudo netplan apply
netplan status --all
```

After restarting services with reboot:

```
sudo reboot
```

SUCCESS!!! WOOHOO!! Both ethernet and wifi connections are now up.

```
$ netplan status
$ curl google.com
```

The host is now remotely accessible on our LAN.

```
ssh jmoore@10.1.1.124
```

### Other useful commands

[uname -mrs] - show kernel version
[sudo lshw -C network] - show hardware information of network adaptors

**References**

Refer to ...:

[url]
