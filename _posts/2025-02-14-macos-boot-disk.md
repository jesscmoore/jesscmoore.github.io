---
layout: post
title:  "Create MacOS boot disk"
date:   2025-02-14 14:45:18 +1100
published: false
toc: true
---

It can be useful to have MacOS usb boot disk, eg. if need to erase the hard drive. After [downloading MacOS]({% post_url 2025-02-14-download_macos_installer %}) disk image, follow this procedure to create a bootable usb drive.

**Summary**

1. [command] - 1 line explanation
2. [command] - 1 line explanation

## Procedure

### Create boot disk

**Note: M1 Mac (Apple Silicon) and Intel i7 Mac have different processor architectures. Do not assume that the MacOS installer downloaded on an M1 will be compatible on an i7 mac.**

Insert a USB drive with minimum capacity 16GB

Open Balena Etcher imaging app which we will use to create a boot disk.

`Applications` > open `Balena Etcher`

Choose 'Flash from file' > select image file to burn

Select target destination drive
