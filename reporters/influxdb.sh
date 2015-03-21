#!/bin/sh

defaults () {
  if [ -z $INFLUXDB_SEND_HOSTNAME ]; then
    INFLUXDB_SEND_HOSTNAME=true
  fi
}

start () {
  if [ -z $INFLUXDB_API_ENDPOINT ]; then
    echo "Error: influxdb requires \$INFLUXDB_API_ENDPOINT to be specified"
    exit 1
  fi

  if [ "$INFLUXDB_SEND_HOSTNAME" = true ]; then
    __influxdb_columns="[\"value\",\"host\"]"
    __influxdb_hostname=$(hostname)
  else
    __influxdb_columns="[\"value\"]"
  fi
}

report () {
  local metric=$1
  local value=$2
  local points
  if [ "$INFLUXDB_SEND_HOSTNAME" = true ]; then
    points="[$value,\"$__influxdb_hostname\"]"
  else
    points="[$value]"
  fi

  curl -X POST $INFLUXDB_API_ENDPOINT \
    -d "[{\"name\":\"$metric\",\"columns\":$__influxdb_columns,\"points\":[$points]}]"
}

docs () {
  echo "Send data to InfluxDB."
  echo "INFLUXDB_API_ENDPOINT=$INFLUXDB_API_ENDPOINT"
  echo "INFLUXDB_SEND_HOSTNAME=$INFLUXDB_SEND_HOSTNAME"
}