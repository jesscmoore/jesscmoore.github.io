---
layout: note
title:  "Install MacOS from Bootable Disk"
date:   2025-02-14 19:26:41 +1100
published: true
toc: true
---

Booting from disk will only be possible on more recent Macs if Startup Security Utility settings have enabled **Allow boot from External Media**.

## Procedure

Power off the Mac.

Insert the bootable installer disk.

Access the Startup (boot) menu by:

Press `Power` + `Option` keys.

Select the bootable installer, then click `Continue` to start the Installer wizard and follow the installation steps

If needing to disable remote management, ensure you disconnect from internet before the last 1-2 minutes of the end of the install routine. Connecting to internet via mobile hotspot is an easy network option, as the computer can be quickly disconnected from the net by turning off the hotspot.

## Troubleshooting

Alternatively, if the bootable USB drive is mounted, OS install wizard can be initiated by running `startosinstall` on the Volume from the Recovery screen. However, this will only be possible if the startup security settings have enabled allow boot from external media.

Access the Recovery screen menu by:

Press `Power`. Then press `CMD` + `R`/

Open `Utilities` menu > select `Terminal`:

```bash
cd /Volumes/Install\ macOS\ Sequoia.app/Contents/Resources/startosinstall
```

For options use:

```bash
...path/to/startosinstall --usage
```

**References**

- [https://support.apple.com/en-us/101578]() - Use the bootable installer
- [https://support.apple.com/en-au/guide/mac-help/mchlp1034/mac](https://support.apple.com/en-au/guide/mac-help/mchlp1034/mac) - Change your Mac startup disk
