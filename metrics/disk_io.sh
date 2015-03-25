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
  readonly fifo=$TEMP_DIR/$(unique_id)_disk_io
  mkfifo $fifo

  if is_osx; then
    bg_proc () {
      iostat -K -d -w $INTERVAL $DISK_IO_MOUNTPOINT | while read line; do
        echo $line | awk '{ print $3 }' > $fifo
      done
    }
  else
    bg_proc () {
      iostat -y -m -d $INTERVAL $DISK_IO_MOUNTPOINT | while read line; do
        echo $line | awk '/[0-9.]/{ print $3 }' > $fifo
      done
    }
  fi

  bg_proc &
}

collect () {
  report $(cat $fifo)
}

stop () {
  if [ ! -z $fifo ] && [ -p $fifo ]; then
    rm $fifo
  fi
}

docs () {
  echo "Disk I/O in MB/s."
  echo "DISK_IO_MOUNTPOINT=$DISK_IO_MOUNTPOINT"
}