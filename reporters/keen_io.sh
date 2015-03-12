#!/bin/sh

init() {
  if [ -z $KEEN_IO_PROJECT_ID ]; then
    echo "Error: keen_io requires \$KEEN_IO_PROJECT_ID to be set"
    exit 1
  fi

  if [ -z $KEEN_IO_WRITE_KEY ]; then
    echo "Error: keen_io requires \$KEEN_IO_WRITE_KEY to be set"
    exit 1
  fi

  if [ -z $KEEN_IO_EVENT_COLLECTION ]; then
    KEEN_IO_EVENT_COLLECTION=$HOSTNAME
  fi

  __keen_io_api_url="https://api.keen.io/3.0"
  __keen_io_api_url+="/projects/$KEEN_IO_PROJECT_ID"
  __keen_io_api_url+="/events/$KEEN_IO_EVENT_COLLECTION"
  __keen_io_api_url+="?api_key=$KEEN_IO_WRITE_KEY"
}

report () {
  METRIC=$1
  VALUE=$2
  curl -s $__keen_io_api_url -H "Content-Type: application/json" \
                  -d "{\"metric\": \"$METRIC\", \"value\": $VALUE}" > /dev/null
}

docs () {
  echo "Send data to Keen IO (https://keen.io)."
  echo "\$KEEN_IO_WRITE_KEY=<write_key>"
  echo "\$KEEN_IO_PROJECT_ID=<project_id>"
  echo "\$KEEN_IO_EVENT_COLLECTION=$KEEN_IO_EVENT_COLLECTION"
}