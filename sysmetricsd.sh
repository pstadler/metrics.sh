#!/bin/sh

# config
INTERVAL=2
REPORTER=stdout

# init
source utils.sh
_METRICS=()

# load reporter
source ./reporters/${REPORTER}.sh
copy_function report _r_${REPORTER}_report
unset -f report

# load metrics
for file in $(find ./metrics -type f -name '*.sh'); do
  source $file
  filename=$(basename $file)
  metric=${filename%.*}
  copy_function collect _m_${metric}_collect
  _METRICS+=($metric)
  unset -f collect
  unset -f init
done

# init metrics
for metric in ${_METRICS[@]}; do
  [ "`type -t _m_${metric}_init`" != 'function' ] && continue
  echo init metric "$metric"
  _m_${metric}_init
done

# collect metrics
while true; do
  for metric in ${_METRICS[@]}; do
    [ "`type -t _m_${metric}_collect`" != 'function' ] && continue
    result=$(_m_${metric}_collect)
    _r_${REPORTER}_report $metric $result
  done

  sleep $INTERVAL
done