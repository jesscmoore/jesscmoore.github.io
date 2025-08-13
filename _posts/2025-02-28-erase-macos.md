---
layout: post
title:  "Erase MacOS Operating System"
date:   2025-02-28 16:49:55 +1100
published: true
toc: true
---

**IMPORTANT:** before erasing the MacOS operating system, make sure to turn on [Allow boot from external media]({% post_url 2025-02-28-allow-ext-boot %}).

The MacOS Recovery screen has functionality to:

- Delete the existing OS on hard drive in **Disk Utility**.
- View/Change startup security settings in **Startup Security Utility**

and reinstall MacOS using one of:

- **Option 1:** Download and install MacOS (requires computer online).
- **Option 2:** Install MacOS from bootable external media (requires permission to boot from external media).

Option 2 is preferrable as this can be the latest MacOS version, which should be downloaded and written to bootable drive before the OS is erased. Option 1 will install the MacOS version that the computer was shipped with and requires internet connection.

## Procedure

Reboot into MacOS Recovery screen and choose erase your MacOS hard disk drive.

`Reboot` > Wait for blank screen > Press `CMD+R`

Open `Disk Utility` > select `Mackintosh HD` volume > click `Erase`

After erasing the MacOS, reboot back to Recovery screen for next steps.
