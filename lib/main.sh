#!/bin/sh

# load utils
for util in ./lib/utils/*.sh; do
  . $util
done

# init
__AVAILABLE_METRICS=
__AVAILABLE_REPORTERS=

main_load () {
  # load reporter
  for file in ./reporters/*.sh; do
    local filename=$(basename $file)
    local reporter=${filename%.*}

    load_reporter_with_prefix __r_${reporter}_ $file

    __AVAILABLE_REPORTERS=$(trim "$__AVAILABLE_REPORTERS $reporter")
  done

  # load available metrics
  for file in ./metrics/*.sh; do
    local filename=$(basename $file)
    local metric=${filename%.*}

    # register metric
    __AVAILABLE_METRICS=$(trim "$__AVAILABLE_METRICS $metric")
  done
}

main_init () {
  # handle args
  __METRICS=$(echo $1 | sed 's/,/ /g')
  __REPORTER=$2

  # create temp dir
  TEMP_DIR=$(make_temp_dir)

  # check if reporter exists
  if ! in_array $__REPORTER "$__AVAILABLE_REPORTERS"; then
    echo "Error: reporter '$__REPORTER' is not available"
    exit 1
  fi

  # check if metrics exist
  for metric in $__METRICS; do
    metric=$(get_name $metric)
    if ! in_array $metric "$__AVAILABLE_METRICS"; then
      echo "Error: metric '$metric' is not available"
      exit 1
    fi
  done

  # init reporter
  if is_function __r_${__REPORTER}_config; then
    __r_${__REPORTER}_config
  fi
  if is_function __r_${__REPORTER}_init; then
    __r_${__REPORTER}_init
  fi
}

main_collect () {
  # register trap
  trap '
    trap "" 13
    trap - INT TERM EXIT
    echo Exit signal received.
    kill -13 -$$
  ' 13 INT TERM EXIT

  # collect metrics
  for metric in $__METRICS; do
    # run in subshell to isolate scope
    (
      local metric_name=$(get_name $metric)
      local metric_alias=$(get_alias $metric)
      # used by metrics to return results
      report () {
        local _r_label _r_result
        if [ -z $2 ]; then
          _r_label=$metric_alias
          _r_result="$1"
        else
          _r_label="$metric_alias.$1"
          _r_result="$2"
        fi
        if is_number $_r_result; then
          __r_${__REPORTER}_report $_r_label $_r_result
        fi
      }

      # init metric
      if is_function __m_${metric_alias}_config; then
        __m_${metric_alias}_config
      fi

      load_metric_with_prefix __m_${metric_alias}_ ./metrics/${metric_name}.sh

      if is_function __m_${metric_alias}_init; then
        __m_${metric_alias}_init
      fi

      if ! is_function __m_${metric_alias}_collect; then
        continue
      fi

      # collect metrics
      trap "
        if is_function __m_${metric_alias}_terminate; then
          verbose 'Stopping metric ${metric_alias}'
          __m_${metric_alias}_terminate
        fi
        exit 0
      " 13

      while true; do
        __m_${metric_alias}_collect
        sleep $INTERVAL
      done
    ) &
  done

  # wait until interrupted
  wait
  # then wait again for processes to end
  wait

  main_terminate
}

main_terminate () {
  # terminate reporter
  if is_function __r_${__REPORTER}_terminate; then
    verbose "Stopping reporter ${__REPORTER}"
    __r_${__REPORTER}_terminate
  fi

  verbose -n "Cleaning up..."
  # delete temporary directory
  if [ -d $TEMP_DIR ]; then
    rmdir $TEMP_DIR
  fi
  verbose "done"
}

main_docs () {
  echo "# Metrics"

  for metric in $__AVAILABLE_METRICS; do
    load_metric_with_prefix __m_${metric}_ ./metrics/${metric}.sh

    if ! is_function __m_${metric}_docs; then
      continue
    fi

    echo
    echo "[$metric]"
    __m_${metric}_docs
  done

  echo
  echo "# REPORTERS"
  for reporter in $__AVAILABLE_REPORTERS; do
    if ! is_function __r_${reporter}_docs; then
      continue
    fi

    echo
    echo "[$reporter]"
    __r_${reporter}_docs
  done
}