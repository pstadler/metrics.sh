#!/bin/sh

report () {
  local metric=$1
  local value=$2

  echo $metric: $value
}

docs () {
  echo "Print to standard output, e.g. the TTY you're running the script in."
}