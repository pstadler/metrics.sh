#!/bin/sh

# http://stackoverflow.com/a/1369211/183097
copy_function () {
  declare -F $1 > /dev/null || return 1
  eval "$(echo "${2}()"; declare -f ${1} | tail -n +2)"
}

is_function () {
  [ "`type -t $1`" == 'function' ]
}

OS_TYPE=$(case "$OSTYPE" in
  (solaris*) echo solaris;;
  (darwin*)  echo osx;;
  (linux*)   echo linux;;
  (bsd*)     echo bsd;;
  (*)        echo unknown;;
esac)