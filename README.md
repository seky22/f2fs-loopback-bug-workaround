# F2FS Loopback Bug Workaround
## VR25 @ xda-developers


### Disclaimer
- This mod is provided as is, without warranty of any kind. I shall not be held responsible for anything that may go wrong due to the use/misuse of it.


### Description
- Some kernels from devices with F2FS-formatted data partition (i.e., Motorola) have a bug which prevents loopback devices (.img files) from being mounted read-write. This limits systemless modifications that can be achieved with Magisk.
- This module works by moving magisk.img to the cache partition (`EXT#`) and linking it to its actual location (/data/adb or /data). The other half of the process consists on automatically recreating magisk_merge.img shortly after boot and handling it the same way as magisk.img.
- With this workaround, a patched kernel is dispensable.
- Cache partition's size is the only limiting factor -- and that's pretty much self-explanatory.
- The module automatically backs up (on boot) & restores (on install/update) /cache/magisk_img -- backup file: /data/media/magisk_img_bkp


### Installation
- Due to the nature of the bug, this module can only be installed from recovery mode. Updates are installable from Magisk Manager as well, though.
- Install as a regular flashable zip.


### Notes/Tips
- Reinstall every time after clearing /cache to restore the image backup.
- Always install large modules from recovery mode only -- to avoid issues due to limited cache size.


### Online Info/Support
- [Git Repository](https://github.com/Magisk-Modules-Repo/f2fs-loopback-bug-workaround)
- [XDA Thread](https://forum.xda-developers.com/apps/magisk/guide-magisk-official-version-including-t3577875)


### Recent Changes

**2018.3.6 (201803060)**
- Check whether data and cache have the required filesystems
- Misc optimizations
- Run magisk_merge.img re-creation service in background to prevent delays/interferences in other Magisk tasks
- Upgradeable from Magisk Manager

**2018.1.31 (201801310)**
- Image backup moved to /data/media to comply with Magisk Hide policies and survive factory resets
- Major optimizations
- Two image backups are now performed as opposed to just one
- Updated reference

**2018.1.24 (201801240)**
- Automatically find and remove original Magisk image files so that users don't have to
- General optimizations
