#!/bin/sh

init () {
  if [ -z $STATHAT_API_KEY ]; then
    echo "Error: stathat requires \$STATHAT_API_KEY to be set"
    exit 1
  fi
}

report () {
  METRIC=$1
  VALUE=$2
  curl -s -d "stat=$METRIC&ezkey=$STATHAT_API_KEY&value=$VALUE" \
                                      http://api.stathat.com/ez > /dev/null
}

docs () {
  echo "Send data to StatHat (https://www.stathat.com)."
  echo "\$STATHAT_API_KEY=<ez_key>"
}