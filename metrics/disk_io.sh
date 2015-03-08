# #!/bin/sh

# if [ -z $DISK_IO_MOUNTPOINT ]; then
#   if is_osx; then
#     DISK_IO_MOUNTPOINT="disk0"
#   else
#     DISK_IO_MOUNTPOINT="/dev/vda"
#   fi
# fi

# if is_osx; then
#   __disk_io_bgproc () {
#     iostat -K -d -c 99999 -w $INTERVAL $DISK_IO_MOUNTPOINT | while read line; do
#       echo $line | awk '{print $3}' > ./foobar
#     done
#   }
# else
#   __disk_io_bgproc () {
#     echo $(iostat -y -d 1 $DISK_IO_MOUNTPOINT)
#   }
# fi

# init () {
#   mkfifo ./foobar
#   #exec 3<> ./foobar
#   __disk_io_bgproc > ./foobar &
# }

# collect () {
#   cat ./foobar
# }