#!/bin/sh

defaults () {
  if [ -z $STATSD_HOST ]; then
    STATSD_HOST="127.0.0.1"
  fi
  if [ -z $STATSD_PORT ]; then
    STATSD_PORT=8125
  fi
}

start () {
  if [ -n "$STATSD_PREFIX" ]; then
    prefix="$STATSD_PREFIX."
  fi
}

report () {
  local metric=$1
  local value=$2
  echo "$prefix$metric:$value|g" | nc -u -w0 $STATSD_HOST $STATSD_PORT
}

docs () {
  echo "Send data to StatsD using the gauges metric type."
  echo "STATSD_HOST=$STATSD_HOST"
  echo "STATSD_PORT=$STATSD_PORT"
  echo "STATSD_PREFIX=$STATSD_PREFIX"
}