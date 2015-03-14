#!/bin/sh

report () {
  local METRIC=$1
  local VALUE=$2
  echo $METRIC: $VALUE
}

docs () {
  echo "Print to standard output (e.g. the TTY you're running the script in)"
}