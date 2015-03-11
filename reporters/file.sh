#!/bin/sh

report () {
  local METRIC=$1
  local VALUE=$2
  local DATE=$(iso_date)
  echo "$DATE $METRIC: $VALUE" >> $FILE_LOCATION
}

init () {
  if [ -z $FILE_LOCATION ]; then
    echo "Missing configuration: \$FILE_LOCATION"
    return 1
  fi

  if [ ! -f $FILE_LOCATION ]; then
    touch $FILE_LOCATION
  fi
}

docs () {
  echo "Write to a file or named pipe."
  echo "\$FILE_LOCATION=$FILE_LOCATION"
}