---
layout: post
title:  "Disable Remote Management"
date:   2025-02-28 22:11:17 +1100
published: true
toc: true
---

These steps are required while the newly installed MacOS is offline.

## Procedure

### Disable System Integrity Protection

Reboot into MacOS Recovery screen:

`Reboot` > Wait for blank screen > Press `CMD+R`

Open Terminal app, disable SIP and reboot to MacOS:

Select `Utilities` > `Terminal`

```bash
csrutil disable
reboot
```

### Remove Mobile Device Management

From Terminal app in the MacOS Desktop, remove the Mobile Device Management profiles

Open `Terminal`.

```bash
sudo rm /var/db/ConfigurationProfiles/Settings/.cloudConfigHasActivationRecord
sudo rm /var/db/ConfigurationProfiles/Settings/.cloudConfigRecordFound
sudo touch /var/db/ConfigurationProfiles/Settings/.cloudConfigProfileInstalled
sudo touch /var/db/ConfigurationProfiles/Settings/.cloudConfigRecordNotFound
```

Confirm they have been deleted:

```bash
sudo profiles show -type enrollment
```

Stop profiles being restored:

```bash
sudo launchctl disable system/com.apple.ManagedClient.enroll
```

Block domains used by Mac to recover MDM profiles:

```bash
vim /etc/hosts
```

And add:

```console
# Block MDM Remote Management
0.0.0.0 iprofiles.apple.com
0.0.0.0 mdmenrollment.apple.com
0.0.0.0 deviceenrollment.apple.com
0.0.0.0 gdmf.apple.com
0.0.0.0 acmdm.apple.com
0.0.0.0 albert.apple.com
```

### Re-enable System Integrity Protection

Reboot back into Recovery system to restart SIP:

`Reboot` > Wait for blank screen > Press `CMD+R`

Open Terminal app, disable SIP and reboot to MacOS:

Select `Utilities` > `Terminal`

```bash
csrutil enable
reboot
```

### Reconnect to internet and update MacOS

Back in MacOS Desktop, reconnect to internet.

Then confirm the system is not remotely managed with:

```bash
sudo profiles show -type enrollment
```

Any MacOS updates can now be installed.
