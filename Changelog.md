**2018.7.24 (201807240)**
- Fixed modPath detection issue (Magisk V16.6).
- Updated documentation

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

**2018.1.14 (201801140)**
- Automatically backup (on boot) & restore (on install/update) /cache/magisk_img -- backup file: /data/magisk_img_bkp
- Better device compatibility, regardless of TWRP F2FS patching status
- Works with all Magisk versions currently in use

**2018.1.1 (201801010)**
- Auto-remove $IMG symlink before installing -- people who followed the manual workaround no longer need to do anything prior to installing
- Enhanced magisk_merge.img creation service
- Updated reference

**2017.12.31 (201712310)**
- Initial version
- Initial release
