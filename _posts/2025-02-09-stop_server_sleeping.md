---
layout: note
title:  "How to stop server from sleeping"
date:   2025-02-09 21:32:37 +1100
published: false
toc: true
---

Edit default sleep configuration to prevent sleep on closing laptop lid.

**Summary**

1. Create `/etc/systemd/logind.conf.d` directory for user customisation of lid closure behaviour.
2. Edit `/etc/systemd/logind.conf.d/60-logind.conf` to customise lid closure behaviour.
3. `reboot`  - restart to apply changes
3. `sudo systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target` - suspend sleep

## Procedure

### Customise lid close behaviour

The file `/etc/systemd/logind.conf` configures the parameters of the systemd login manager. A user customisation of login configuration should be stored in `/etc/systemd/logind.conf.d` folder with filename prefix in range `60-` to `90-` and ending in `.conf`.

```bash
sudo mkdir -p /etc/systemd/logind.conf.d
```

```bash
sudo cat >> /etc/systemd/logind.conf.d/60-logind.conf <<'EEOF'
HandleLidSwitch=ignore
HandleLidSwitchExternalPower=ignore
LidSwitchIgnoreInhibited=no
EEOF
```

Then apply changes with:

```bash
reboot
```

### Disable suspend daemon

The suspend daemon is disabled with this command:

```bash
sudo systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target
Created symlink '/etc/systemd/system/sleep.target' → '/dev/null'.
Created symlink '/etc/systemd/system/suspend.target' → '/dev/null'.
Created symlink '/etc/systemd/system/hibernate.target' → '/dev/null'.
Created symlink '/etc/systemd/system/hybrid-sleep.target' → '/dev/null'.
```

Status of `sleep.target`, `suspend.target` and `hibernate.target` and `hybrid-sleep.target` should show:

```bash
sudo systemctl status sleep.target suspend.target hibernate.target hybrid-sleep.target
○ sleep.target
    Loaded: masked (Reason: Unit sleep.target is masked.)
    Active: inactive (dead) since Sun 2025-02-09 21:46:27 AEDT; 1min 53s ago
Invocation: 68611bc4da304f2a9510d54ba7ba12e1

Feb 09 21:46:08 budmeister systemd[1]: Reached target sleep.target - Sleep.
Feb 09 21:46:27 budmeister systemd[1]: Stopped target sleep.target - Sleep.

○ suspend.target
    Loaded: masked (Reason: Unit suspend.target is masked.)
    Active: inactive (dead) since Sun 2025-02-09 21:46:27 AEDT; 1min 53s ago
Invocation: 5c42cd45b5b44299bc3bfc268d061eb8

Feb 09 21:46:27 budmeister systemd[1]: Reached target suspend.target - Suspend.
Feb 09 21:46:27 budmeister systemd[1]: Stopped target suspend.target - Suspend.

○ hibernate.target
    Loaded: masked (Reason: Unit hibernate.target is masked.)
    Active: inactive (dead)

○ hybrid-sleep.target
    Loaded: masked (Reason: Unit hybrid-sleep.target is masked.)
    Active: inactive (dead)
```


**References**

- https://medium.com/@t.deb41/how-to-turn-your-old-macbook-into-a-home-server-2bb04a5277f7
