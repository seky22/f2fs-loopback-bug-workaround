# F2FS Loopback Bug Workaround
## (c) 2017-2018, VR25 @ xda-developers
### License: GPL v3+



#### DISCLAIMER

- This software is provided as is, in the hope that it will be useful, but without any warranty. Always read the reference prior to installing/updating. While no cats have been harmed, I assume no responsibility under anything that might go wrong due to the use/misuse of it.
- A copy of the GNU General Public License, version 3 or newer ships with every build. Please, read it prior to using, modifying and/or sharing any part of this work.
- To prevent fraud, DO NOT mirror any link associated with this project.



#### DESCRIPTION

- Some kernels from devices with F2FS-formatted data partition (i.e., Motorola) have a bug which prevents loopback devices (.img files) from being mounted read-write. This limits systemless modifications that can be achieved with Magisk.
- This module works by moving magisk.img to the cache partition (`EXT[2-4]`) and linking it to its actual location (/data/adb or /data). The other half of the process consists on automatically recreating magisk_merge.img shortly after boot and handling it the same way as magisk.img.
- With this workaround, a patched kernel is dispensable.
- Cache partition's size is the only limiting factor -- and that's pretty much self-explanatory.
- The module automatically backs up (on boot) & restores (on install/update) /cache/magisk_img -- backup file: /data/media/magisk_img_bkp



#### PRE-REQUISITES 

- Magisk
- F2FS-formatted data partition
- EXT[2-4]-formatted cache partition



#### SETUP

- Due to the nature of the bug, this module can only be installed from recovery mode. Updates are installable from Magisk Manager as well, though.
- Install as a regular flashable zip.



#### NOTES/TIPS

- Reinstall after factory resets or /cache formating to restore magisk.img backup. Yes, the image is set to survive the standard TWRP factory reset.
- Always install large modules from recovery mode only -- to avoid issues due to limited cache size. In fact, I recommend installing every module from recovery if your device's cache partition has a very small size (i.e., only a few MegaBytes).



#### ONLINE SUPPORT

- [Git Repository](https://github.com/Magisk-Modules-Repo/f2fs-loopback-bug-workaround)
- [XDA Thread](https://forum.xda-developers.com/apps/magisk/guide-magisk-official-version-including-t3577875)



#### RECENT CHANGES

**2018.8.1 (201808010)**
- General optimizations
- Striped down (removed unnecessary code & files)
- Updated documentation

**2018.7.24 (201807240)**
- Fixed modPath detection issue (Magisk V16.6).
- Updated documentation

**2018.3.6 (201803060)**
- Check whether data and cache have the required filesystems
- Misc optimizations
- Run magisk_merge.img re-creation service in background to prevent delays/interferences in other Magisk tasks
- Upgradeable from Magisk Manager
