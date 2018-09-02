#!/system/bin/sh
# F2FS Loopback Bug Workaround
# Create magisk_merge.img & backup /cache/magisk_.img
# VR25 @ xda-developers


main() {

  set -u

  modId=f2fsfix
  modPath=${0%/*}
  magiskDir=/data/adb
  Img=/cache/magisk_.img
  Log=$modPath/${modId}.log
  imgBkp=$magiskDir/magisk.img.bkp
  mergeImg=/cache/magisk_merge_.img
  magiskBin=$magiskDir/magisk/magisk
  origImg=$magiskDir/magisk_merge.img

  # log engine
  [ -f "$Log" ] && mv $Log ${Log}.old
  PS4='[$EPOCHREALTIME] '
  exec 1>$Log 2>&1
  set -x

  # remount cache partition rw
  mount -o remount,rw /cache

  # backup /cache/magisk_.img if necessary
  get_sizeof() { du $1 2>/dev/null | cut -f1; }
  [ "$(get_sizeof $Img)" != "$(get_sizeof $imgBkp)" ] && cp -af $Img $imgBkp

  # create magisk_merge_.img
 $magiskBin imgtool create $mergeImg 8
 [ -f "$mergeImg" ] || $magiskBin --createimg $mergeImg 8 # fallback
 ln -fs $mergeImg $origImg # link to original location
 
 exit 0
}

(main) &
