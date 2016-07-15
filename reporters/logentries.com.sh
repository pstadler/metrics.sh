#!/bin/sh

start () {
  if [ -z $LOGENTRIES_TOKEN ]; then
    echo "Error: logentries.com requires \$LOGENTRIES_TOKEN to be specified"
    return 1
  fi
}

report () {
  local metric=$1 # the name of the metric, e.g. "cpu", "cpu_alias", "cpu.foo"
  local value=$2  # int or float
  echo "$LOGENTRIES_TOKEN $metric=$value" | nc data.logentries.com 10000
}

docs () {
  echo "Send data to Logentries.com using token TCP (https://docs.logentries.com/docs/input-token)"
  echo "LOGENTRIES_TOKEN=$LOGENTRIES_TOKEN"
}
