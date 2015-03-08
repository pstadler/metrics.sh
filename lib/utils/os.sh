#!/bin/sh

declare -r OS_TYPE=$(case "$OSTYPE" in
  (solaris*) echo solaris;;
  (darwin*)  echo osx;;
  (linux*)   echo linux;;
  (bsd*)     echo bsd;;
  (*)        echo unknown;;
esac)

is_solaris () { [ $OS_TYPE == 'solaris' ]; }
is_osx ()     { [ $OS_TYPE == 'osx' ]; }
is_linux ()   { [ $OS_TYPE == 'solaris' ]; }
is_bsd ()     { [ $OS_TYPE == 'bsd']; }
is_unknown () { [ $OS_TYPE == 'unknown' ]; }


make_temp_dir () {
  if is_osx; then
    mktemp -d -t 'sysmetrics'
  else
    mktemp -d
  fi
}