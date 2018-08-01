#!/system/bin/sh
# F2FS Loopback Bug Workaround -- magisk_merge.img
# VR25 @ xda-developers


main() {

  modPath=${0%/*}
  PATH=/sbin/.core/busybox:/dev/magisk/bin:$PATH

  # verbosity engine
  newLog=$modPath/service.sh_verbose_log.txt
  oldLog=$modPath/service.sh_verbose_previous_log.txt
  [[ -f $newLog ]] && mv $newLog $oldLog
  set -x 2>>$newLog

	# remount cache partition rw
	mount -o remount,rw /cache
	
	# backup /cache/magisk_img
	imgBkp=/data/media/magisk_img_bkp
	[[ -f $imgBkp ]] && mv $imgBkp /data/media/magisk_img_previous_bkp
  rm /data/media/last_magisk_img_bkp 2>/dev/null ###
	[ -f /cache/magisk_img ] && cp -af /cache/magisk_img $imgBkp

	# create new magisk_merge image
	make_ext4fs -l 8M /cache/magisk_merge_img 2>/dev/null \
    || make_ext4fs /cache/magisk_merge_img 8M 2>/dev/null
	[ -d /data/adb/magisk ] \
		&& ln -s /cache/magisk_merge_img /data/adb/magisk_merge.img \
		|| ln -s /cache/magisk_merge_img /data/magisk_merge.img
}

(main) &
