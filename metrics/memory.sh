#!/bin/sh

if [ $OS_TYPE == "osx" ]; then

  # FIXME: total_memory leaks out
  total_memory=$(sysctl -n hw.memsize)

  collect () {
    echo $(vm_stat | awk -v total_memory=$total_memory \
              'BEGIN {FS="   *"; pages=0}
               /Pages (free|inactive|speculative)/ {pages+=$2}
               END {printf "%.2f", 100 - (pages * 4096) / total_memory * 100.0}')
  }

else

  collect () {
    echo $(free | awk '/buffers\/cache/{printf "%.2f", $4 / ($3 + $4) * 100.0}')
  }

fi