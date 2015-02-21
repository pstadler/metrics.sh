#!/bin/sh

report () {
  METRIC=$1
  VALUE=$2
  curl -d "stat=$METRIC&ezkey=$API_KEY&value=$VALUE" http://api.stathat.com/ez
}