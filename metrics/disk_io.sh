#!/bin/sh

defaults () {
  if [ -z $DISK_IO_MOUNTPOINT ]; then
    if is_osx; then
      DISK_IO_MOUNTPOINT="disk0"
    else
      DISK_IO_MOUNTPOINT="/dev/vda"
    fi
  fi
}

start () {
  readonly __disk_io_fifo=$TEMP_DIR/$(unique_id)
  mkfifo $__disk_io_fifo

  if is_osx; then
    __disk_io_bgproc () {
      iostat -K -d -w $INTERVAL $DISK_IO_MOUNTPOINT | while read line; do
        echo $line | awk '{ print $3 }' > $__disk_io_fifo
      done
    }
  else
    __disk_io_bgproc () {
      iostat -y -m -d $INTERVAL $DISK_IO_MOUNTPOINT | while read line; do
        echo $line | awk '/[0-9.]/{ print $3 }' > $__disk_io_fifo
      done
    }
  fi

  __disk_io_bgproc &
}

collect () {
  report $(cat $__disk_io_fifo)
}

stop () {
  if [ ! -z $__disk_io_fifo ] && [ -p $__disk_io_fifo ]; then
    rm $__disk_io_fifo
  fi
}

docs () {
  echo "Disk I/O in MB/s."
  echo "DISK_IO_MOUNTPOINT=$DISK_IO_MOUNTPOINT"
}