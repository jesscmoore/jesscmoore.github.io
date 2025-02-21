---
layout: post
title:  "Remove remote management from MacOS"
date:   2025-02-14 21:11:11 +1100
published: false
toc: true
---

Removing remote management requires erasing the MacOS installation and removing the external Mobile Device Management profile (MDM) during a fresh installation while the machine is disconnected from the internet to prevent reinstall of the MDM profile.


## Procedure

[Download MacOS]({% post_url 2025-02-14-download_macos_installer %}).

Burn MacOS onto a [bootable USB drive]({% post_url 2025-02-14-macos-boot-disk %}).

### Allow boot from external disk

**This must be done before the disk is erased as it requires a working operating system with admin user.** Reboot into MacOS Recovery screen. Open Startup Security Utility, enter admin password, select Allow boot from USB. Reboot to apply.

Reboot, then after screen goes blank press CMD+R to access Recovery mode.

Open `Startup Security Utility` with:

`Utilities` > `Startup Security Utility`.

Default settings are `Full Security` and `Disallow booting from external or removable media` which prevents using an external boot disk. Change it to no security and allow booting from external media. This will allow user to boot from operating systems on external media that are not signed by Apple, such as ome might need to change to a non MacOS operating system.

```console
Secure Boot: No Security
Allowed Boot Media: Allow booting from external or removable media
```



Reboot into MacOS Recovery screen and choose erase your MacOS hard disk drive. In Recovery screen, open

`Disk Utility` > select `Mackintosh HD` volume > click Erase.



Reboot into MacOS Recovery screen and [install MacOS]({% post_url 2025-02-14-install-macOS-boot-disk %}).

Disable System Integrity Protection.

Remove Mobile Device Management Profile.

Update MacOS.



**References**

- [https://williamhartz.medium.com/how-to-remove-remote-management-screen-from-macbook-without-password-2023-486ac1476acc](https://williamhartz.medium.com/how-to-remove-remote-management-screen-from-macbook-without-password-2023-486ac1476acc)
- [https://medium.com/@perbcreate/how-to-remove-remote-management-mdm-from-m1-macbook-without-a-password-983a8f93427a](https://medium.com/@perbcreate/how-to-remove-remote-management-mdm-from-m1-macbook-without-a-password-983a8f93427a)
