#!/bin/sh

if [ -z $DISK_USAGE_MOUNTPOINT ]; then
  if is_osx; then
    DISK_USAGE_MOUNTPOINT="/dev/disk1"
  else
    DISK_USAGE_MOUNTPOINT="/dev/vda"
  fi
fi

collect () {
  report $(df | awk -v disk_regexp="^$DISK_USAGE_MOUNTPOINT" \
                  '$0 ~ disk_regexp {printf "%.1f", $5}')
}

docs () {
  echo "Disk usage percentage for a file system at a given mount point."
  echo "\$DISK_USAGE_MOUNTPOINT=$DISK_USAGE_MOUNTPOINT"
}