#!/bin/sh

defaults () {
  if [ -z $UDP_HOST ]; then
    UDP_HOST="127.0.0.1"
  fi
  if [ -z $UDP_DELIMITER ]; then
    UDP_DELIMITER="="
  fi
}

start () {
  if [ -z $UDP_PORT ]; then
    echo "Error: udp requires \$UDP_PORT to be specified"
    return 1
  fi

  if [ -n "$UDP_PREFIX" ]; then
    prefix="$UDP_PREFIX."
  fi
  if [ -n "$UDP_DELIMITER" ]; then
    delimiter="$UDP_DELIMITER"
  fi
}

report () {
  local metric=$1
  local value=$2
  echo "$prefix$metric$delimiter$value" | nc -u -w0 $UDP_HOST $UDP_PORT
}

docs () {
  echo "Send data to any service using UDP."
  echo "UDP_HOST=$UDP_HOST"
  echo "UDP_PORT=$UDP_PORT"
  echo "UDP_PREFIX=$UDP_PREFIX"
  echo "UDP_DELIMITER=\"$UDP_DELIMITER\""
}