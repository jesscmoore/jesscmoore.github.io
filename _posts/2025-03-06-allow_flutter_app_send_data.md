---
layout: post
title:  "Allow flutter app to send and receive data"
date:   2025-03-06 10:46:54 +1100
published: true
toc: true
---

Flutter app that queries an API must send and receive data by making incoming and outgoing network connections. This permission is required for apps on windows, macos, iOS and Android platforms. Apps tested on `Simulator` do not require this permission.

- `com.apple.security.network.client` - controls whether outgoing network connections are allowed.
- `com.apple.security.network.server` - controls whether incoming network connections are allowed.

Both must be set to `true` to allow an app to query an api and receive data.

### MacOS apps

By default, `com.apple.security.network.server` is already set to true in debug mode entitlements file and is neither is set in the release mode entitlements file.

Edit `macos/Runner/DebugProfile.entitlements` and `macos/Runner/Release.entitlements` such that both are set to true with:

```
<dict>
    <key>com.apple.security.network.server</key>
    <true/>
    <key>com.apple.security.network.client</key>
    <true/>
</dict>
```



**References**

- [https://developer.apple.com/documentation/bundleresources/entitlements/com.apple.security.network.client](https://developer.apple.com/documentation/bundleresources/entitlements/com.apple.security.network.client)
