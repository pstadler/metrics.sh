#!/bin/sh

# config
INTERVAL=1
REPORTER=file

# register trap
trap '
  main_terminate
  trap - SIGTERM && kill -- -$$ SIGINT SIGTERM EXIT
' SIGINT SIGTERM EXIT

# load and start main routine
source ./lib/main.sh
main_load
main_init
main_collect