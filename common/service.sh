#!/system/bin/sh
# F2FS Loopback Bug Workaround -- magisk_merge.img
# VR25 @ XDA Developers

export PATH="/sbin/.core/busybox:/dev/magisk/bin:$PATH"
export ModPath=${0%/*}

Actions() {
	# Remount cache partition rw
	mount -o remount,rw /cache
	
	# Backup /cache/magisk_img
	BkpImg=/data/media/magisk_img_bkp
	[ -f $BkpImg ] && mv $BkpImg /data/media/last_magisk_img_bkp
	[ -f /cache/magisk_img ] && cp -af /cache/magisk_img $BkpImg

	# Create new magisk_merge image
	make_ext4fs -l 8M /cache/magisk_merge_img 2>/dev/null
	ln -s /cache/magisk_merge_img /data/adb/magisk_merge.img 2>/dev/null
	ln -s /cache/magisk_merge_img /data/magisk_merge.img 2>/dev/null
}

(Actions) &
