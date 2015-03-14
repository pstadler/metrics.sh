#!/bin/sh

init () {
  if [ -z $INFLUXDB_API_ENDPOINT ]; then
    echo "Error: influxdb requires \$INFLUXDB_API_ENDPOINT to be specified"
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
  local metric=$1
  local value=$2
  local points
  if [ "$INFLUXDB_SEND_HOSTNAME" = true ]; then
    points="[$value,\"$HOSTNAME\"]"
  else
    points="[$value]"
  fi

  curl -X POST $INFLUXDB_API_ENDPOINT \
    -d "[{\"name\":\"$metric\",\"columns\":$__influxdb_columns,\"points\":[$points]}]"
}

docs () {
  echo "Send data to InfluxDB."
  echo "\$INFLUXDB_API_ENDPOINT="
  echo "\$INFLUXDB_SEND_HOSTNAME=$INFLUXDB_SEND_HOSTNAME"
}