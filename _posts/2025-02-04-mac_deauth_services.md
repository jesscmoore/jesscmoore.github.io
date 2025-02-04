---
layout: post
title:  "How to deauthorise a macbook from key services"
date:   2025-02-04 13:24:20 +1100
published: false
toc: true
---

How to deauthorise a mac computer from key services prior to erasing/reinstalling the operating system or gifting the computer.

**Summary**

1. [command] - 1 line explanation
2. [command] - 1 line explanation

## Procedure

### External Management

Check to see if the machine is externally managed, e.g. by your employer.

[Preferences] > `Software Update` > look for mention of external management.

If found, additional steps need to be done during boot setup to erase the remote management profile.


### iTunes

Deauthorise this machine from your iTunes:

Open [iTunes] > `Account` > `Authorisations` > `Deauthorise this Computer`.

This may take several minutes as is often the case with Apple authorisations.


### iCloud

Sign out of iCloud on your device:

Open `Preferences` > `iCloud` > `Sign Out`

If this doesn't work, login to https://icloud.com and deauthorise your computer.

Go to `https://icloud.com` > `Settings` > `Find devices` > select your macbook > click `Remove`


### Messages

Similarly sign out of `Messages` app:

Open `Messages` > `Preferences` or `Settings` > `iMessage` > click `Sign out`


### Bluetooth

Unpair devices that connect by bluetooth to the machine.

Open `System Settings` > `Bluetooth` > R-click each device and click `Forget` or `Remove`

This machine is now somewhat unauthorised from your services.


**References**

- [https://support.apple.com/en-us/104958] - sign out of iCloud services.
