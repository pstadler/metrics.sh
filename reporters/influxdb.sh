#!/bin/sh

init () {
  if [ -z $INFLUXDB_API_ENDPOINT ]; then
    echo "Error: influxdb requires \$INFLUXDB_API_ENDPOINT to be set"
    exit 1
  fi

  if [ -z $INFLUXDB_SEND_HOSTNAME ]; then
    INFLUXDB_SEND_HOSTNAME=true
  fi

  if [ "$INFLUXDB_SEND_HOSTNAME" = true ]; then
    __influxdb_columns="[\"value\",\"host\"]"
  else
    __influxdb_columns="[\"value\"]"
  fi
}

report () {
  local METRIC=$1
  local VALUE=$2
  if [ "$INFLUXDB_SEND_HOSTNAME" = true ]; then
    local POINTS="[$VALUE,\"$HOSTNAME\"]"
  else
    local POINTS="[$VALUE]"
  fi
  curl -X POST $INFLUXDB_API_ENDPOINT \
    -d "[{\"name\":\"$METRIC\",\"columns\":$__influxdb_columns,\"points\":[$POINTS]}]"
}

docs () {
  echo "Send data to InfluxDB."
  echo "\$INFLUXDB_API_ENDPOINT="
  echo "\$INFLUXDB_SEND_HOSTNAME=$INFLUXDB_SEND_HOSTNAME"
}