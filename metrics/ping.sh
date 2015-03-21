#!/bin/sh

start () {
  if [ -z $PING_REMOTE_HOST ]; then
    echo "Error: ping metric requires \$PING_REMOTE_HOST to be specified"
    exit 1
  fi
}

collect () {
  ping -c 1 $PING_REMOTE_HOST > /dev/null 2>&1
  if [ $? -eq 0 ]; then
    report 1
  else
    report 0
  fi
}

docs () {
  echo "Check if remote host is reachable by sending a single ping."
  echo "Reports '1' if ping was successful, '0' if not."
  echo "PING_REMOTE_HOST=$PING_REMOTE_HOST"
}