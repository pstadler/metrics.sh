#!/bin/sh

collect () {
  report $(ps axo %cpu | awk '{ sum+=$1 } END { printf "%.1f\n", sum }' | tail -n 1)
}

docs () {
  echo "CPU load percentage."
}