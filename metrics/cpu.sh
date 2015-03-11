#!/bin/sh

collect () {
  report $(ps aux | awk '{ sum+=$3 } END { printf "%.1f\n", sum }' | tail -n 1)
}

docs () {
  echo "CPU load percentage."
}