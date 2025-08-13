---
layout: note
title:  "How to download macOS full installer"
date:   2025-02-14 14:38:57 +1100
published: true
toc: true
---

The full MacOS installer is required to create a bootable MacOS install disk.

**Summary**

1. `softwareupdate --list-full-installers` - list available versions
2. `softwareupdate --fetch-full-installer --full-installer-version 15.3` - download specific version, e.g. 15.3

## Procedure

### Download MacOS

List available MacOS versions

    $ softwareupdate --list-full-installers

    Finding available software
    Software Update found the following full installers:
    * Title: macOS Sequoia, Version: 15.3.1, Size: 14891477KiB, Build: 24D70, Deferred: NO
    * Title: macOS Sequoia, Version: 15.3, Size: 14889290KiB, Build: 24D60, Deferred: NO
    * Title: macOS Sequoia, Version: 15.2, Size: 14921025KiB, Build: 24C101, Deferred: NO
    * Title: macOS Sequoia, Version: 15.1.1, Size: 14212458KiB, Build: 24B91, Deferred: NO
    * Title: macOS Sequoia, Version: 15.1, Size: 14209591KiB, Build: 24B83, Deferred: NO
    * Title: macOS Sonoma, Version: 14.7.4, Size: 13332546KiB, Build: 23H420, Deferred: NO
    * Title: macOS Sonoma, Version: 14.7.3, Size: 13334287KiB, Build: 23H417, Deferred: NO
    * Title: macOS Sonoma, Version: 14.7.2, Size: 13333067KiB, Build: 23H311, Deferred: NO
    * Title: macOS Sonoma, Version: 14.7.1, Size: 13339062KiB, Build: 23H222, Deferred: NO
    * Title: macOS Ventura, Version: 13.7.4, Size: 11915317KiB, Build: 22H420, Deferred: NO
    * Title: macOS Ventura, Version: 13.7.3, Size: 11915737KiB, Build: 22H417, Deferred: NO
    * Title: macOS Ventura, Version: 13.7.2, Size: 11916651KiB, Build: 22H313, Deferred: NO
    * Title: macOS Ventura, Version: 13.7.1, Size: 11923883KiB, Build: 22H221, Deferred: NO
    * Title: macOS Monterey, Version: 12.7.4, Size: 12117810KiB, Build: 21H1123, Deferred: NO

Download MacOS Sequoia v15.3 disk image:

    softwareupdate --fetch-full-installer --full-installer-version 15.3

## Troubleshooting

### PKDownload Error Code=8

If download fails with following error

$ softwareupdate --fetch-full-installer --full-installer-version 15.3
Scanning for 15.3 isntaller
Install failed with error: Installation failed
Error Domain=PKDownloadError Code=8 "null" ... "A server with the specified hostname could not be found."

it is likely that internet connection cut out midway through the download. Switch to ethernet or mobile hotspot, which may have a more sustained connection than wifi.

And added OpenDNS nameservers.

`Settings` > `Network` > selected `Ethernet connection` > clicked `Details` > `DNS` > selected `+` > added `208.67.222.222` and `208.67.220.220`

And restarted download.

**References**

- <https://discussions.apple.com/thread/255182110?answerId=259942918022&sortBy=rank#259942918022>
- <https://www.opendns.com/setupguide/>
- <https://apple.stackexchange.com/questions/372785/pkdownloaderror-error-8-upon-catalina-update>
