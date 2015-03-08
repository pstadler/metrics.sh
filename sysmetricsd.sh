#!/bin/sh

# config
INTERVAL=1
REPORTER=stdout

# load utils
for util in ./lib/utils/*.sh; do source $util; done

# init
__METRICS=()
__TEMP_DIR=$(make_temp_dir)

# register trap
trap '
  for metric in ${__METRICS[@]}; do
    if ! is_function __m_${metric}_terminate; then
      continue
    fi
    __m_${metric}_terminate
  done
  trap - SIGTERM && kill -- -$$ SIGINT SIGTERM EXIT
' SIGINT SIGTERM EXIT

# load reporter
source ./reporters/${REPORTER}.sh
copy_function init      __r_${REPORTER}_init
copy_function report    __r_${REPORTER}_report
copy_function terminate __r_${REPORTER}_terminate
copy_function docs      __r_${REPORTER}_docs
unset -f init report terminate docs

# load metrics
for file in ./metrics/*.sh; do
  filename=$(basename $file)
  metric=${filename%.*}

  # soruce file and copy functions
  source $file
  copy_function init      __m_${metric}_init
  copy_function collect   __m_${metric}_collect
  copy_function terminate __m_${metric}_terminate
  copy_function docs      __m_${metric}_docs
  unset -f init collect terminate docs

  # register metric
  __METRICS+=($metric)
done

# init metrics
for metric in ${__METRICS[@]}; do
  if ! is_function __m_${metric}_init; then
    continue
  fi

  __m_${metric}_init
done

# print docs for metrics
echo "Available metrics:"
for metric in ${__METRICS[@]}; do
  if ! is_function __m_${metric}_docs; then
    continue
  fi

  echo "[$metric]"
  __m_${metric}_docs
  echo
done

report () {
  local result
  if [ -z $2 ]; then
    label=$metric
    result="$1"
  else
    label="$metric.$1"
    result="$2"
  fi
  __r_${REPORTER}_report $label $result
}

# collect metrics
while true; do
  for metric in ${__METRICS[@]}; do
    if ! is_function __m_${metric}_collect; then
      continue
    fi

    __m_${metric}_collect
  done

  sleep $INTERVAL
done