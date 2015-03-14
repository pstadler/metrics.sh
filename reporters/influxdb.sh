#!/bin/sh

init () {
  if [ -z $INFLUXDB_API_ENDPOINT ]; then
    echo "Error: influxdb requires \$INFLUXDB_API_ENDPOINT to be set"
    exit 1
  fi
}

report () {
  local METRIC=$1
  local VALUE=$2
  curl -X POST $INFLUXDB_API_ENDPOINT \
    -d "[{\"name\":\"$METRIC\",\"columns\":[\"value\"],\"points\":[[$VALUE]]}]"
}

docs () {
  echo "Send data to InfluxDB."
  echo "\$INFLUXDB_API_ENDPOINT="
}