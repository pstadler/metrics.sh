#!/bin/sh

report () {
  METRIC=$1
  VALUE=$2
  curl -d "stat=$METRIC&ezkey=$API_KEY&value=$VALUE" http://api.stathat.com/ez
}

docs () {
  echo "Send data to StatHat (https://www.stathat.com)."
  echo "\$API_KEY=<ez_key>"
}