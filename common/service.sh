#!/system/bin/sh
# F2FS Loopback Bug Workaround
# Create $mergeImg & backup $img
# Copyright (C) 2017-2018, VR25 @ xda-developers
# License: GPL v3+


# shell behavior
set -u

modPath=${0%/*}
magiskDir=/data/adb
img=/cache/magisk_.img
log=$modPath/service.sh.log
imgBkp=$magiskDir/magisk.img.bkp
mergeImg=/cache/magisk_merge_.img
magiskBin=$magiskDir/magisk/magisk
origImg=$magiskDir/magisk_merge.img

# verbose
[ -f $log ] && mv $log $log.old
exec 1>>$log 2>&1
set -x

# remount cache partition rw
mount -o remount,rw /cache

# backup /cache/magisk_.img if necessary
get_sizeof() { du $1 2>/dev/null | cut -f 1; }
[ "$(get_sizeof $img)" -ne "$(get_sizeof $imgBkp)" ] && cp -af $img $imgBkp

# [re]create $mergeImg
$magiskBin imgtool create $mergeImg 8 \
  || $magiskBin --createimg $mergeImg 8 # fallback
ln -fs $mergeImg $origImg

exit 0
