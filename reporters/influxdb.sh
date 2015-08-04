#!/bin/sh

defaults () {
  if [ -z $INFLUXDB_SEND_HOSTNAME ]; then
    INFLUXDB_SEND_HOSTNAME=true
  fi
}

start () {
  if [ -z $INFLUXDB_API_ENDPOINT ]; then
    echo "Error: influxdb requires \$INFLUXDB_API_ENDPOINT to be specified"
    return 1
  fi

  if [ "$INFLUXDB_SEND_HOSTNAME" = true ]; then
    __influxdb_hostname="host=$(hostname)"
  fi
}

report () {
  local metric=$1
  local value=$2
  local points
  local data="$metric,$__influxdb_hostname value=$value"
  curl  -s -X POST $INFLUXDB_API_ENDPOINT --data-binary "$data"
}

docs () {
  echo "Send data to InfluxDB."
  echo "INFLUXDB_API_ENDPOINT=$INFLUXDB_API_ENDPOINT"
  echo "INFLUXDB_SEND_HOSTNAME=$INFLUXDB_SEND_HOSTNAME"
}
