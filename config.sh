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
LATESTARTSERVICE=false

##########################################################################################
# Installation Message
##########################################################################################

# Set what you want to show when installing your mod

print_modname() {
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
  for f in $MODPATH/bin/* $MODPATH/system/bin/* $MODPATH/system/xbin/* $MODPATH/*.sh; do
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


# exit trap (debugging tool)
debug_exit() {
  local e=$?
  echo -e "\n***EXIT $e***\n"
  set +euxo pipefail
  set
  echo
  echo "SELinux status: $(getenforce 2>/dev/null || sestatus 2>/dev/null)" \
    | sed 's/En/en/;s/Pe/pe/'
  exxit $e $e 1>/dev/null 2>&1
} >&2
trap debug_exit EXIT


install_module() {

  set -euxo pipefail

  # create module paths
  rm -rf $MODPATH 2>/dev/null || true
  mkdir -p $MODPATH

  # extract module files
  ui_print "- Extracting module files"
  unzip -o "$ZIP" -d $INSTALLER >&2
  cd $INSTALLER
  mv common/* $MODPATH/

  set +euxo pipefail
}


exxit() {
  set +euxo pipefail
  if [ "$2" -ne 0 ]; then
    unmount_magisk_img
    $BOOTMODE || recovery_cleanup
    set -u
    rm -rf $TMPDIR
  fi
  exit $1
}


exxitM() {
  ui_print " "
  ui_print "(!) $1 partition is not mounted!"
  [ $1 = cache ] \
    && ui_print "- Note: if your device doesn't have a cache partition, this module is not for you."
  ui_print " "
  exxit 1
}


prep_environment() {

  # shell behavior
  set -euxo pipefail

  curVer=""
  img=/cache/magisk_.img
  magiskVer=${MAGISK_VER/.}
  utilFunc=$MAGISKBIN/util_functions.sh
  magiskDir=$(echo $MAGISKBIN | sed 's:/magisk::')

  origImg=$magiskDir/magisk.img
  imgBkp=$magiskDir/magisk.img.bkp

  $BOOTMODE && MOUNTPATH0=$(sed -n 's/^.*MOUNTPATH=//p' $utilFunc | head -n 1) \
    || MOUNTPATH0=$MOUNTPATH

  curVer=$(grep_prop versionCode $MOUNTPATH0/$MODID/module.prop || true)
  [ -n "$curVer" ] || curVer=0
}


fix_f2fs() {

  prep_environment

  # block bootmode installation
  if $BOOTMODE && [ ! -f $MOUNTPATH0/$MODID/module.prop ]; then
		ui_print " "
		ui_print "(!) Install from custom recovery!"
		ui_print "- Updates and reinstalls can be carried out from Magisk Manager as well."
		ui_print " "
		exxit 1
	fi

  # enforce safe install
  if $BOOTMODE && [ $curVer -lt 201809020 ]; then
    ui_print " "
    ui_print "(!) Detected legacy version installed!"
    ui_print "- magisk.img must be migrated."
    ui_print "- Upgrade from custom recovery."
    ui_print " "
    exxit 1
  fi

  if ! $BOOTMODE; then
    mount /cache 2>/dev/null || true

    ui_print "- Verifying mounts"
    is_mounted /data || exxitM data
    is_mounted /cache || exxitM cache

    ui_print "- Checking cache and data file systems"
    if ! grep '/data' /proc/mounts | grep -iq 'f2fs'; then
      ui_print " "
      ui_print "(!) Data partition file system is not F2FS!"
      ui_print "- This module is not for you."
      ui_print " "
      exxit 1
    fi
    if ! grep '/cache' /proc/mounts | grep -iq 'ext[2-4]'; then
      ui_print " "
      ui_print "(!) Cache partition file system must be EXT[2-4]!"
      ui_print " "
      exxit 1
    fi

    # restore magisk.img backup
    if [ ! -f "$img" ] && [ -f "$imgBkp" ]; then
      ui_print "- Restoring magisk.img backup"
      cp -a $imgBkp $img
    fi

    ui_print "- Implementing F2FS workaround"

    # legacy support & cleanup
    set +e
    { mv -f /cache/magisk_img /cache/magisk_.img
    [ -h $origImg ] || mv -f $origImg $img
    mv -f /data/media/magisk_img_bkp $imgBkp
    rm /data/media/last_magisk_img_bkp; } 2>/dev/null
    set -e

    if [ ! -f $img ]; then
      $MAGISKBIN/magisk imgtool create $img 8 >&2 \
        || $MAGISKBIN/magisk --createimg $img 8 >&2 # fallback
    fi
    mkdir -p $magiskDir
    ln -fs $img $origImg
  fi

  set +euxo pipefail
}


i() {
  local p=$INSTALLER/module.prop
  [ -f $p ] || p=$MODPATH/module.prop
  grep_prop $1 $p
}


version_info() {

  local c="" whatsNew="- Bug fixes
- Latest module template, with added sugar.
- Magisk 15-17.2 support
- Updated documentation"

  set -euxo pipefail

  ui_print " "
  ui_print "  WHAT'S NEW"
  echo "$whatsNew" | \
    while read c; do
      ui_print "    $c"
    done
  ui_print " "

  # a note on untested Magisk versions
  if [ "$magiskVer" -gt 172 ]; then
    ui_print " "
    ui_print "(i) This Magisk version hasn't been tested by @VR25!"
    ui_print "- If you come across any issue, please report."
    ui_print " "
  fi

  ui_print "  LINKS"
  ui_print "    - Facebook Page: facebook.com/VR25-at-xda-developers-258150974794782/"
  ui_print "    - Git Repository: github.com/Magisk-Modules-Repo/f2fs-loopback-bug-workaround/"
  ui_print "    - XDA Thread: forum.xda-developers.com/apps/magisk/guide-magisk-official-version-including-t3577875/"
  ui_print " "
}
