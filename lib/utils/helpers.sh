#!/bin/sh

is_number () {
  [ ! -z "$1" ] && printf '%f' "$1" > /dev/null 2>&1
}

iso_date () {
  date -u +"%Y-%m-%dT%H:%M:%SZ"
}

in_array () {
  local item=$1
  local arr=$2
  echo " $2 " | grep -q " $1 "
}

trim () {
  echo $1 | sed -e 's/^[[:space:]]*//g' -e 's/[[:space:]]*\$//g'
}