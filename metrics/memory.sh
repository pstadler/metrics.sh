#!/bin/sh

if is_osx; then
  declare -r __memory_os_memsize=$(sysctl -n hw.memsize)

  collect () {
    report $(vm_stat | awk -v total_memory=$__memory_os_memsize \
            'BEGIN {FS="   *"; pages=0}
             /Pages (free|inactive|speculative)/ {pages+=$2}
             END {printf "%.1f", 100 - (pages * 4096) / total_memory * 100.0}')
  }
else
  collect () {
    report $(free | awk '/buffers\/cache/{printf "%.1f", 100 - $4 / ($3 + $4) * 100.0}')
  }
fi

docs () {
  echo "Percentage of used memory."
}