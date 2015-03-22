#!/bin/sh

start () {
  if [ -z $STATHAT_API_KEY ]; then
    echo "Error: stathat requires \$STATHAT_API_KEY to be specified"
    return 1
  fi
}

report () {
  local metric=$1
  local value=$2

  curl -s http://api.stathat.com/ez \
       -d "ezkey=$STATHAT_API_KEY&stat=$metric&value=$value"
}

docs () {
  echo "Send data to StatHat (https://www.stathat.com)."
  echo "STATHAT_API_KEY=$STATHAT_API_KEY"
}