#!/bin/sh

if [ -z $DISK_IO_MOUNTPOINT ]; then
  if is_osx; then
    DISK_IO_MOUNTPOINT="disk0"
  else
    DISK_IO_MOUNTPOINT="/dev/vda"
  fi
fi

if is_osx; then
  __disk_io_bgproc () {
    iostat -K -d -w $INTERVAL $DISK_IO_MOUNTPOINT | while read line; do
      echo $line | awk '{print $3}' > $__disk_io_fifo
    done
  }
else
  __disk_io_bgproc () {
    echo $(iostat -y -d 1 $DISK_IO_MOUNTPOINT)
  }
fi

__disk_io_fifo=$__TEMP_DIR/disk_io

init () {
  __disk_io_bgproc &
  mkfifo $__disk_io_fifo
}

collect () {
  report $(cat $__disk_io_fifo)
}

terminate () {
  rm $__disk_io_fifo
}

docs () {
  echo "Disk I/O in MB/s."
  echo "\$DISK_IO_MOUNTPOINT=$DISK_IO_MOUNTPOINT"
}