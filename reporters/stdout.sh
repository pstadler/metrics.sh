#!/bin/sh

report () {
  METRIC=$1
  VALUE=$2
  echo $METRIC: $VALUE
}

docs () {
  echo "Print to standard output (e.g. the TTY you're running the script in)"
}