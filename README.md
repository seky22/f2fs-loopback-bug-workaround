# F2FS Loopback Bug Workaround
## README.md
### Copyright (C) 2017-2018, VR25 @ xda-developers
#### License: GPL v3+



---
#### DISCLAIMER

This software is provided as is, in the hope that it will be useful, but without any warranty. Always read/reread this reference prior to installing/upgrading. While no cats have been harmed, I assume no responsibility under anything which might go wrong due to the use/misuse of it.

A copy of the GNU General Public License, version 3 or newer ships with every build. Please, read it prior to using, modifying and/or sharing any part of this work.

To prevent fraud, DO NOT mirror any link associated with this project; DO NOT share ready-to-flash-builds (zips) on-line!



---
#### DESCRIPTION

Some kernels from devices with F2FS-formatted data partition (i.e., Motorola) have a bug which prevents loopback devices (.img files) from being mounted read-write. This limits systemless modifications that can otherwise be achieved with Magisk.

This module works by moving magisk.img to the cache partition (EXT[2-4]-formatted) and linking it to its actual location (i.e., /data/adb/magisk.img). The other half of the process consists on automatically recreating magisk_merge.img shortly after boot and handling it the same way as magisk.img.

With this workaround, a patched kernel is dispensable.

Cache partition's size is essentially the only limiting factor -- and that's pretty much self-explanatory.

/cache/magisk_.img is automatically backed up to/data/adb on boot (only if modified) & restored on install. Thus, whenever cache is wiped, magisk_.img and its respective symlink can easily be restored by simply reinstalling the module.



---
#### PRE-REQUISITES

- Magisk v15+
- F2FS-formatted data partition
- EXT[2-4]-formatted cache partition



---
#### SETUP STEPS

Fist time
- Install from custom recovery as a regular flashable zip.


Upgrades
- Install from Magisk Manager or custom recovery.
- Reinstall after cache wipes to restore magisk.img backup.



---
#### NOTES/TIPS

Always install large modules from custom recovery only. In fact, I recommend installing every module from recovery if your device's cache partition has a very small size (i.e., only a few Megabytes).

To revert changes, uninstall the module, boot into custom recovery and delete </data/adb/magisk.img> & <magisk.img.bkp>. Lastly (while still in custom recovery), move </cache/magisk_.img> to </data/adb/magisk.img>.

Updates and reinstalls can be carried out from Magisk Manager as well.



---
#### ONLINE SUPPORT

- [Facebook Support Page](https://facebook.com/VR25-at-xda-developers-258150974794782/)
- [Git Repository](https://github.com/Magisk-Modules-Repo/f2fs-loopback-bug-workaround/)
- [XDA Thread](https://forum.xda-developers.com/apps/magisk/guide-magisk-official-version-including-t3577875/)



---
#### RECENT CHANGES

**2018.10.9 (201810090)**
- Bug fixes
- Latest module template, with added sugar.
- Magisk 15-17.2 support
- Updated documentation

**2018.9.2 (201809020)**
- Improved compatibility
- Major optimizations
- Updated documentation

**2018.8.1 (201808010)**
- General optimizations
- Striped down (removed unnecessary code & files)
- Updated documentation

**2018.7.24 (201807240)**
- Fixed modPath detection issue (Magisk V16.6).
- Updated documentation
