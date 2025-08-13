---
layout: post
title:  "Allow boot from external media"
date:   2025-02-28 16:05:15 +1100
published: true
toc: true
---


**IMPORTANT: This must be done before the disk is erased as it requires a working operating system with admin user.**

Permission to allow boot from external media is set from the **Startup Security Utility** which is only accessible from **Recovery mode**:

`Reboot` > Wait for blank screen > Press `CMD+R`

Open `Utilities` > `Startup Security Utility`

Default settings are **Full Security** and **Disallow booting from external or removable media** which prevents using an external boot disk. We require no security and allow booting from external media, to allow user to boot from operating systems on external media that are not signed by Apple, such as one might need to change to a non MacOS operating system.

```console
Secure Boot: No Security
Allowed Boot Media: Allow booting from external or removable media
```
