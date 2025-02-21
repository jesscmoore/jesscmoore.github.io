---
layout: note
title:  "Create MacOS boot disk"
date:   2025-02-14 14:45:18 +1100
published: false
toc: true
---

It can be useful to have MacOS usb boot disk, eg. if need to erase the hard drive. After [downloading MacOS]({% post_url 2025-02-14-download_macos_installer %}) disk image, follow this procedure to create a bootable usb drive.

Two options are described below. Use Option 1 to create a boot disk of a `.dmg` disk image and use Option 2 to make a boot disk of a `Install MacOS [versionName].app`.

**Note: M1 Mac (Apple Silicon) and Intel i7 Mac have different processor architectures. Do not assume that the MacOS installer downloaded on an M1 will be compatible on an i7 mac.**

## Procedure

### Option 1: Burning a .dmg


Insert a USB drive with minimum capacity 16GB

Open Balena Etcher imaging app which we will use to create a boot disk.

`Applications` > open `Balena Etcher`

Choose 'Flash from file' > select image file to burn

Select target destination drive


### Option 2: Burning a Install\ Sequoia.app

The `softwareupdate` app downloads an installer application. This needs to be burned to boot disk with:

    $ sudo /Applications/Install\ macOS\ Sequoia.app/Contents/Resources/createinstallmedia --volume /Volumes/[volname]

where `volname` is the name of your USB volume.

A non-empty storage disk will need to first be erased, which can be done with the Disk Utility app or on command line.


## Troubleshooting

### `createinstallmedia` hangs after erasing drive

If the `createinstallmedia` process does not progress after erasing the disk, it is likely that another app is monopolising the drive after it was remounted, preventing it from being written to by `createinstallmedia`. See which processes are using the drive:

```bash
sudo lsof +D /Volumes/[volname]
```

If it shows `mds` or `mds_store`, this is the `Spotlight.app`. Prevent Spotlight from reading the volume by opening:

`System Preferences` > Spotlight > Privacy and drag the /Volumes/[volname] folder from Finder into the box

Then reboot, and retry `createinstallmedia`.



## References

- https://support.apple.com/en-us/101578 - Create a bootable installer for macOS
