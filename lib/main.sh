#!/bin/sh

# load utils
for util in ./lib/utils/*.sh; do
  . $util
done

# init
__AVAILABLE_METRICS=
__AVAILABLE_REPORTERS=

main_defaults () {
  if [ -z $INTERVAL ]; then
    INTERVAL=2
  fi
  if [ -z $METRICS ]; then
    METRICS=cpu,disk_io,disk_usage,heartbeat,memory,network_io,swap
  fi
  if [ -z $REPORTER ]; then
    REPORTER=stdout
  fi
}

main_load () {
  # set defaults
  main_defaults

  # load reporter
  for file in ./reporters/*.sh; do
    local filename=$(basename $file)
    local reporter=${filename%.*}

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
}

main_collect () {
  # check if reporter exists
  if ! in_array $(get_name_for_reporter $__REPORTER) "$__AVAILABLE_REPORTERS"; then
    echo "Error: reporter '$__REPORTER' is not available"
    exit 1
  fi

  # check if metrics exist
  for metric in $__METRICS; do
    if ! in_array $(get_name_for_metric $metric) "$__AVAILABLE_METRICS"; then
      echo "Error: metric '$metric' is not available"
      exit 1
    fi
  done

  # register trap
  trap '
    trap "" 13
    trap - INT TERM EXIT
    echo Exit signal received.
    kill -13 -$$
  ' 13 INT TERM EXIT

  # init reporter
  local reporter_name=$(get_name_for_reporter $__REPORTER)
  local reporter_alias=$(get_alias $__REPORTER)
  load_reporter_with_prefix __r_${reporter_alias}_ ./reporters/${reporter_name}.sh

  if is_function __r_${reporter_alias}_defaults; then
    __r_${reporter_alias}_defaults
  fi
  if is_function __r_${reporter_alias}_config; then
    __r_${reporter_alias}_config
  fi
  if is_function __r_${reporter_alias}_start; then
    __r_${reporter_alias}_start
  fi

  # collect metrics
  for metric in $__METRICS; do
    # run in subshell to isolate scope
    (
      local metric_name=$(get_name_for_metric $metric)
      local metric_alias=$(get_alias $metric)

      # init metric
      load_metric_with_prefix __m_${metric_alias}_ ./metrics/${metric_name}.sh

      if is_function __m_${metric_alias}_defaults; then
        __m_${metric_alias}_defaults
      fi

      if is_function __m_${metric_alias}_config; then
        __m_${metric_alias}_config
      fi

      if is_function __m_${metric_alias}_start; then
        __m_${metric_alias}_start
      fi

      if ! is_function __m_${metric_alias}_collect; then
        continue
      fi

      # collect metrics
      trap "
        verbose \"Stopping metric '${metric_alias}'\"
        if is_function __m_${metric_alias}_stop; then
          __m_${metric_alias}_stop
        fi
        exit 0
      " 13

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
          __r_${reporter_alias}_report $_r_label $_r_result
        fi
      }

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
  # stop reporter
  local reporter_alias=$(get_alias $__REPORTER)
  verbose "Stopping reporter '${reporter_alias}'"
  if is_function __r_${reporter_alias}_stop; then
    __r_${reporter_alias}_stop
  fi

  verbose "Cleaning up..."
  # delete temporary directory
  if [ -d $TEMP_DIR ]; then
    rmdir $TEMP_DIR
  fi
  verbose "done"
}

main_print_docs () {
  echo "# METRICS"

  for metric in $__AVAILABLE_METRICS; do
    load_metric_with_prefix __m_${metric}_ ./metrics/${metric}.sh

    if ! is_function __m_${metric}_docs; then
      continue
    fi

    if is_function __m_${metric}_defaults; then
      __m_${metric}_defaults
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

    if is_function __r_${reporter}_defaults; then
      __r_${reporter}_defaults
    fi

    echo
    echo "[$reporter]"
    __r_${reporter}_docs
  done
}

main_print_config () {
  echo "[metrics.sh]"
  echo ";INTERVAL=$INTERVAL"
  echo ";METRICS=$METRICS"
  echo ";REPORTER=$REPORTER"

  for metric in $__AVAILABLE_METRICS; do
    load_metric_with_prefix __m_${metric}_ ./metrics/${metric}.sh

    if is_function __m_${metric}_defaults; then
      __m_${metric}_defaults
    fi

    echo
    echo ";[metric $metric]"
    if ! is_function __m_${metric}_docs; then
      continue
    fi
    print_prefixed ";" "$(__m_${metric}_docs)"
  done

  for reporter in $__AVAILABLE_REPORTERS; do
    if ! is_function __r_${reporter}_docs; then
      continue
    fi

    if is_function __r_${reporter}_defaults; then
      __r_${reporter}_defaults
    fi

    echo
    echo ";[reporter $reporter]"
    print_prefixed ";" "$(__r_${reporter}_docs)"
  done
}