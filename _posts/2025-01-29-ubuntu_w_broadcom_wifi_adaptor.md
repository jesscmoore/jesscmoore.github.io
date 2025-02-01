---
layout: post
title:  "Ubuntu: how to connect to wifi with Broadcom Wireless Adaptor"
date:   2025-01-29 16:19:29 +1100
published: false
toc: true
---

Some Broadcom Wireless Adaptors require drivers that are not supported out of the box with the Ubuntu Server 24.04.1 LTS.

**Summary**

1. `lspci --n |grep Network` -List wireless network adaptor name and version
2. `uname -nrm` - List kernerl version
3. `apt-cache search broadcom linux-headers` - Search for broadcom and linux header packages
4. `sudo apt-get install linux-headers-6.11.0-14-generic broadcom-sta-dkms && sudo apt autoremove` - install required package for this wifi adaptor
5. `sudo modprobe -v -r b44 b43 b43legacy brcmsmac` - Remove conflicting already installed broadcom modules
6. `sudo modprobe -v wl` - Install required broadcom module
7. `netplan status --all` - Identify wireless interface name
8. `sudo apt install nmcli wpa_supplicant` - Install wpa_supplicant also required
9. `sudo vim /etc/netplan/00-installer-config.yaml` - Configure wifi interface with SSID and other settings
10. `sudo netplan generate` - Use /etc/netplan to generate the required configuration for the renderers.
11. `sudo netplan apply` - Apply all network interface configurations for the renderer, restarting them as necessary.
12. `sudo systemctl restart systemd-networkd.service` - restart networkd service.
13. `netplan status --all` - Review status of each network interface.



## Procedure

### Network management tool

The default network management tool in ubuntu >=24.04 is `networkd`.

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

<!-- TODO: repeat without `nmcli`. check wpa_supplicant and/or nmcli is required -->

```
$ sudo apt install nmcli wpa_supplicant
$ sudo nmcli d
```

### Configure wifi network interface

Edit your netplan yaml file to configure the wifi interface with our access point credentials and other settings. Additionally define network renderer as `networkd` for clarity.

Configure wireless interface with netplan:
```
sudo vim /etc/netplan/00-installer-config.yaml
```
and add renderer setting and wifis block:
```
  renderer: networkd
  wifis:
    wlp3s0:
      dhcp4: yes
      dhcp6: yes
      access-points:
        "your SSID 2.4GHz":
          password: "your pw"
```

After applying the configuration, netplan will show wlp3s0 state UNKNOWN.

```
sudo netplan generate
sudo netplan apply
netplan status --all
```

Restart networkd service

```
sudo systemctl restart systemd-networkd.service
```

SUCCESS!!! WOOHOO!! Both ethernet and wifi connections are now up.

```
$ netplan status
$ curl google.com
```

The host is now remotely accessible on our LAN after ethernet cable disconnected.

```
ssh jmoore@10.1.1.124
```

Reconnecting ethernet cable does automatically restart ethernet interface (note: as we're using a Thunderbolt to ethernet adaptor, it does need to be fully pushed in.)

### Configure static IP address

#### Add static lease

In browser, login to modem wizard and adjusted Local Network settings to add new static lease.

Click `Local Network` > `Add new static lease` and add:
```
`Hostname`: `[my_hostname]`
`MAC address`: `[wifi interface MAC address]`
`IP`: `[my_static_ip]`
```

where the static IP is within range `10.1.1.0/24`.

Find out the DNS server by clicking 'Show advanced'.


#### Configure network for static IP

Update netplan configuration to use static lease

```
sudo vim /etc/netplan/50-cloud-init.yaml
```
and change wifis block to:
```
  wifis:
    wlp3s0:
      dhcp4: false
      dhcp6: false
      addresses:
        - [my_static_ip]/24
      routes:
        - to: 10.1.0.0/16
          via: 10.1.1.1
      nameservers:
        addresses: [8.8.8.8, 8.8.4.4]
      access-points:
        "your SSID":
          password: "your pw"
        "your SSID 5GHz":
          password: "your pw"
```

where `10.1.1.1` is modem gateway, and `8.8.8.8` and `8.8.4.4` are public nameservers provided by Google. `routes.to` is set to `10.1.0.0/16` instead of `default`, as `default` is used for ethernet interface routing.


#### Apply static IP

Apply updated netplan configuration and restart networkd service.
```
netplan generate
netplan apply
systemctl restart systemd-networkd.service
```

Check wifi status
```
netplan status --all | grep wifi
```

Check IP address matches the static IP lease.

```
ip -br add show wlp3s0 | awk '{print $1, $2, $3}'
ip route |grep wlp3s0 | head -n 1
```

### Other useful commands

- `uname -mrs` - Shows kernel version.
- `sudo lshw -C network` - Shows hardware information of network adaptors.
- [lsusb] - Lists all USB devices connected to the system, including their PID and VID.
- [lsmod] - Lists loaded driver modules.
- `sudo systemctl status systemd-networkd.service` - Show status and recent log of networkd service.
- `sudo systemctl restart systemd-networkd.service` - Restart networkd service.
- `ip -br add show [interface] | awk '{print $1, $2, $3}'` - Show status and IP address of specific interface.
- `ip route |grep wlp3s0 | head -n 1` - Show gateway route and lease type.


**References**

[https://ubuntu.com/server/docs/configuring-networks] - for more on networkd configuration with netplan, eg. static addresses, interface name and other settings, and taking interfaces up or down..
