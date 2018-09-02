##########################################################################################
#
# Magisk Module Template Config Script
# by topjohnwu
#
##########################################################################################
##########################################################################################
#
# Instructions:
#
# 1. Place your files into system folder (delete the placeholder file)
# 2. Fill in your module's info into module.prop
# 3. Configure the settings in this file (config.sh)
# 4. If you need boot scripts, add them into common/post-fs-data.sh or common/service.sh
# 5. Add your additional or modified system properties into common/system.prop
#
##########################################################################################

##########################################################################################
# Configs
##########################################################################################

# Set to true if you need to enable Magic Mount
# Most mods would like it to be enabled
AUTOMOUNT=false

# Set to true if you need to load system.prop
PROPFILE=false

# Set to true if you need post-fs-data script
POSTFSDATA=false

# Set to true if you need late_start service script
LATESTARTSERVICE=true

##########################################################################################
# Installation Message
##########################################################################################

# Set what you want to show when installing your mod

print_modname() {
  i() { grep_prop $1 $INSTALLER/module.prop; }
  ui_print " "
  ui_print "$(i name) $(i version)"
  ui_print "$(i author)"
  ui_print " "
}

##########################################################################################
# Replace list
##########################################################################################

# List all directories you want to directly replace in the system
# Check the documentations for more info about how Magic Mount works, and why you need this

# This is an example
REPLACE="
/system/app/Youtube
/system/priv-app/SystemUI
/system/priv-app/Settings
/system/framework
"

# Construct your own list here, it will override the example above
# !DO NOT! remove this if you don't need to replace anything, leave it empty as it is now
REPLACE="
"

##########################################################################################
# Permissions
##########################################################################################

set_permissions() {
  # Only some special files require specific permissions
  # The default permissions should be good enough for most cases

  # Here are some examples for the set_perm functions:

  # set_perm_recursive  <dirname>                <owner> <group> <dirpermission> <filepermission> <contexts> (default: u:object_r:system_file:s0)
  # set_perm_recursive  $MODPATH/system/lib       0       0       0755            0644

  # set_perm  <filename>                         <owner> <group> <permission> <contexts> (default: u:object_r:system_file:s0)
  # set_perm  $MODPATH/system/bin/app_process32   0       2000    0755         u:object_r:zygote_exec:s0
  # set_perm  $MODPATH/system/bin/dex2oat         0       2000    0755         u:object_r:dex2oat_exec:s0
  # set_perm  $MODPATH/system/lib/libart.so       0       0       0644

  # The following is default permissions, DO NOT remove
  set_perm_recursive  $MODPATH  0  0  0755  0644

  # Permissions for executables
  for f in $MODPATH/bin/* $MODPATH/system/bin/* $MODPATH/system/xbin/*; do
    [ -f "$f" ] && set_perm $f  0  0  0755
  done
}

##########################################################################################
# Custom Functions
##########################################################################################

# This file (config.sh) will be sourced by the main flash script after util_functions.sh
# If you need custom logic, please add them here as functions, and call these functions in
# update-binary. Refrain from adding code directly into update-binary, as it will make it
# difficult for you to migrate your modules to newer template versions.
# Make update-binary as clean as possible, try to only do function calls in it.


exxit() {
  $BOOTMODE || recovery_cleanup
  rm -rf $TMPDIR
	exit $1
}


fix_f2fs() {

  set -ux

  Img=/cache/magisk_.img
  magiskDir=$(echo $MAGISKBIN | sed 's:/magisk::')

  origImg=$magiskDir/magisk.img
  imgBkp=$magiskDir/magisk.img.bkp
  utilFunc=$magiskDir/util_functions.sh
  MOUNTPATH0=$(sed -n 's/^.*MOUNTPATH=//p' $utilFunc | head -n1)

  curVer="$(grep_prop versionCode $MOUNTPATH0/$MODID/module.prop)"
  set +u
  [ -z "$curVer" ] && curVer=0
  set -u

  # do not support Magisk 16.7 (bugged)
  if [ "$MAGISK_VER_CODE" -eq 1671 ]; then
		ui_print " "
		ui_print "(!) Magisk 16.7 is officially unsupported!"
		ui_print "- It has some big and scary bugs which love eating several modules' heads."
    ui_print "- Try a newer Magisk version or downgrade to 15.0-16.6."
		ui_print " "
    exxit 1
  fi

  # block bootmode installation
  if $BOOTMODE && [ ! -f $MOUNTPATH0/$MODID/module.prop ]; then
		ui_print " "
		ui_print "(!) Install from TWRP!"
		ui_print "- Updates and reinstalls can be carried out from Magisk Manager as well."
		ui_print " "
		exxit 1
	fi

  # enforce safe install
  if $BOOTMODE && [ "$curVer" -lt 201809020 ]; then
    ui_print " "
    ui_print "(!) Detected legacy version installed!"
    ui_print "- magisk.img must be migrated."
    ui_print "- Upgrade from TWRP."
    ui_print " "
    exxit 1
  fi

  if ! $BOOTMODE; then
    mount /cache 2>/dev/null

    # check whether partitions are mounted
    ui_print "- Verifying mounts"
    exxit() {
      ui_print " "
      ui_print "(!) $1 partition is not mounted!"
      ui_print "- Note: if your device doesn't have a cache partition, this module is not for you."
      ui_print " "
      exit 1
    }
    is_mounted /data || exxit data
    is_mounted /cache || exxit cache

    # check whether cache is F2FS-formated
    ui_print "- Checking cache and data file systems"
    if ! grep '/data' /proc/mounts | grep -iq 'f2fs'; then
      ui_print " "
      ui_print "(!) Data partition file system is not F2FS!"
      ui_print "- This module is not for you."
      ui_print " "
      exit 1
    fi
    if ! grep '/cache' /proc/mounts | grep -iq 'ext[2-4]'; then
      ui_print " "
      ui_print "(!) Cache partition file system must be EXT[2-4]!"
      ui_print " "
      exit 1
    fi

    # restore magisk.img backup
    if [ ! -f "$Img" ] && [ -f "$imgBkp" ]; then
      ui_print "- Restoring magisk.img backup"
      cp -a $imgBkp $Img
    fi

    ui_print "- Implementing F2FS workaround"
    # legacy support & cleanup
    { mv -f /cache/magisk_img /cache/magisk_.img
    [ -h "$origImg" ] || mv -f $origImg $Img
    mv -f /data/media/magisk_img_bkp $imgBkp
    rm /data/media/last_magisk_img_bkp; } 2>/dev/null

    if [ ! -f "$Img" ]; then
      $MAGISKBIN/magisk imgtool create $Img 8 >&2
      [ -f "$Img" ] || $MAGISKBIN/magisk --createimg $Img 8 >&2 # fallback
    fi
    mkdir $magiskDir 2>/dev/null
    ln -fs $Img $origImg # link to original location
  fi
  set +u
}


install_module() {
  set -u
  # create module paths
  rm -rf $MODPATH 2>/dev/null
  mkdir -p $MODPATH
  set +u
}


version_info() {

  set -u

  ui_print " "
  ui_print "  Facebook Support Page: https://facebook.com/VR25-at-xda-developers-258150974794782/"
  ui_print " "

  whatsNew="- Improved compatibility
- Major optimizations
- Updated documentation"

  ui_print "  WHAT'S NEW"
  echo "$whatsNew" | \
    while read c; do
      ui_print "  $c"
    done
  ui_print "    "

  # a note on untested Magisk versions
  if [ "$MAGISK_VER_CODE" -gt 1671 ]; then
    # abort installation
		ui_print " "
		ui_print "(i) This Magisk version hasn't been tested by @VR25 as of yet."
		ui_print "- Should you find any issue, try a newer Magisk version if available, or downgrade to 15.0-16.6."
    ui_print "- And don't forget to share your experience(s)! ;)"
		ui_print " "
  fi
}
