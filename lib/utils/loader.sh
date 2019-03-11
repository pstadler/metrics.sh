#!/bin/sh

get_available_reporters () {
  local result
  for file in `ls ${DIR}/reporters/*.sh $CUSTOM_REPORTERS_PATH/*.sh 2> /dev/null`; do
    local filename=$(basename $file)
    local reporter=${filename%.*}
    result=$(echo "$result $reporter")
  done
  echo $result
}

get_available_metrics () {
  local result
  for file in `ls ${DIR}/metrics/*.sh $CUSTOM_METRICS_PATH/*.sh 2> /dev/null`; do
    local filename=$(basename $file)
    local metric=${filename%.*}
    # register metric
    result=$(trim "$result $metric")
  done
  echo $result
}

load_reporter_with_prefix () {
  local prefix=$1
  local name=$2

  local file
  for dir in $CUSTOM_REPORTERS_PATH ${DIR}/reporters; do
    if [ -f $dir/$name.sh ]; then
      file=$dir/$name.sh
      break
    fi
  done

  if [ -z $file ]; then
    return 1
  fi

  local content
  content=$(sed \
          -e 's/^[[:space:]]*\(defaults[ ]*()[ ]*{\)/'"$prefix"'\1/' \
          -e 's/^[[:space:]]*\(start[ ]*()[ ]*{\)/'"$prefix"'\1/' \
          -e 's/^[[:space:]]*\(report[ ]*()[ ]*{\)/'"$prefix"'\1/' \
          -e 's/^[[:space:]]*\(stop[ ]*()[ ]*{\)/'"$prefix"'\1/' \
          -e 's/^[[:space:]]*\(docs[ ]*()[ ]*{\)/'"$prefix"'\1/' $file)

  eval "$content"
}

load_metric_with_prefix () {
  local prefix=$1
  local name=$2

  local file
  for dir in $CUSTOM_METRICS_PATH ${DIR}/metrics; do
    if [ -f $dir/$name.sh ]; then
      file=$dir/$name.sh
      break
    fi
  done

  if [ -z $file ]; then
    return 1
  fi

  local content
  content=$(sed \
          -e 's/^[[:space:]]*\(defaults[ ]*()[ ]*{\)/'"$prefix"'\1/' \
          -e 's/^[[:space:]]*\(start[ ]*()[ ]*{\)/'"$prefix"'\1/' \
          -e 's/^[[:space:]]*\(collect[ ]*()[ ]*{\)/'"$prefix"'\1/' \
          -e 's/^[[:space:]]*\(stop[ ]*()[ ]*{\)/'"$prefix"'\1/' \
          -e 's/^[[:space:]]*\(docs[ ]*()[ ]*{\)/'"$prefix"'\1/' $file)

  eval "$content"
}
