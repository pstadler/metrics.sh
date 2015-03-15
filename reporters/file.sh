#!/bin/sh

init () {
  if [ -z $FILE_LOCATION ]; then
    echo "Error: file reporter requires \$FILE_LOCATION to be specified"
    exit 1
  fi

  if [ ! -f $FILE_LOCATION ]; then
    touch $FILE_LOCATION
  fi
}

report () {
  local metric=$1
  local value=$2
  local datetime=$(iso_date)
  echo "$datetime $metric: $value" >> $FILE_LOCATION
}

docs () {
  echo "Write to a file or named pipe."
  echo "\$FILE_LOCATION="
}