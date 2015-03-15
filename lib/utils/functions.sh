#!/bin/sh

is_function () {
  declare -f -F $1 > /dev/null; return $?
}

# http://stackoverflow.com/a/1369211/183097
copy_function () {
  is_function $1 || return 1
  eval "$(echo "${2}()"; declare -f ${1} | tail -n +2)"
}