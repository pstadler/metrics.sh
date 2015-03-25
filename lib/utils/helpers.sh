#!/bin/sh

is_number () {
  [ ! -z "$1" ] && printf '%f' "$1" > /dev/null 2>&1
}

iso_date () {
  date -u +"%Y-%m-%dT%H:%M:%SZ"
}

unix_timestamp () {
  date "+%s"
}

in_array () {
  echo " $2 " | grep -q " $1 "
}

trim () {
  echo $1 | sed -e 's/^[[:space:]]*//g' -e 's/[[:space:]]*\$//g'
}

unique_id () {
  RESTORE_LC_ALL=$LC_ALL
  LC_ALL=C
  echo __u_$(cat /dev/urandom | tr -dc 'A-Za-z0-9' | head -c 10)
  LC_ALL=$RESTORE_LC_ALL
}

print_prefixed () {
  printf "$2\n" | sed -e "s/^/$1/g"
}
