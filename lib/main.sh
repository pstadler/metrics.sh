#!/bin/sh

# load utils
for util in ${DIR}/lib/utils/*.sh; do
  . $util
done

main_defaults () {
  if [ -z $INTERVAL ]; then
    INTERVAL=2
  fi
  if [ -z $DEFAULT_METRICS ]; then
    DEFAULT_METRICS=cpu,memory,swap,network_io,disk_io,disk_usage
  fi
  if [ -z $DEFAULT_REPORTER ]; then
    DEFAULT_REPORTER=stdout
  fi
  if [ -z $CUSTOM_REPORTERS_PATH ]; then
    CUSTOM_REPORTERS_PATH=${DIR}/reporters/custom
  fi
  if [ -z $CUSTOM_METRICS_PATH ]; then
    CUSTOM_METRICS_PATH=${DIR}/metrics/custom
  fi
}

main_load () {
  # set defaults
  main_defaults

  __AVAILABLE_REPORTERS=$(get_available_reporters)
  __AVAILABLE_METRICS=$(get_available_metrics)
}

main_init () {
  local metrics="$1"
  local reporter="$2"

  if [ -z "$metrics" ]; then
    metrics=$DEFAULT_METRICS
  fi
  if [ -z "$reporter" ]; then
    reporter=$DEFAULT_REPORTER
  fi

  __METRICS=$(echo $metrics| sed 's/,/ /g')
  __REPORTER=$reporter

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
    echo Exit signal received, stopping...
    kill -13 0
  ' 13 INT TERM EXIT

  # init reporter
  local reporter_name=$(get_name_for_reporter $__REPORTER)
  local reporter_alias=$(get_alias $__REPORTER)
  load_reporter_with_prefix __r_${reporter_alias}_ ${reporter_name}

  if is_function __r_${reporter_alias}_defaults; then
    __r_${reporter_alias}_defaults
  fi

  if is_function __r_${reporter_alias}_config; then
    __r_${reporter_alias}_config
  fi

  verbose "Starting reporter '${reporter_alias}'"
  if is_function __r_${reporter_alias}_start; then
    __r_${reporter_alias}_start
    if [ $? -ne 0 ]; then
      echo "Error: failed to start reporter '${reporter_alias}'"
      exit 1
    fi
  fi

  # collect metrics
  for metric in $__METRICS; do
    # run in subshell to isolate scope
    (
      local metric_name=$(get_name_for_metric $metric)
      local metric_alias=$(get_alias $metric)

      # init metric
      load_metric_with_prefix __m_${metric_alias}_ ${metric_name}

      if is_function __m_${metric_alias}_defaults; then
        __m_${metric_alias}_defaults
      fi

      if is_function __m_${metric_alias}_config; then
        __m_${metric_alias}_config
      fi

      verbose "Starting metric '${metric_alias}'"
      if is_function __m_${metric_alias}_start; then
        __m_${metric_alias}_start
        if [ $? -ne 0 ]; then
          echo "Warning: metric '${metric_alias}' is disabled after it failed to start"
          continue
        fi
      fi

      if ! is_function __m_${metric_alias}_collect; then
        verbose "No collect() function found for '${metric_alias}'"
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

  echo "done"
}

main_print_docs () {
  echo "# GLOBAL"
  echo
  echo "INTERVAL=$INTERVAL"
  echo "DEFAULT_REPORTER=$DEFAULT_REPORTER"
  echo "DEFAULT_METRICS=$DEFAULT_METRICS"
  echo "CUSTOM_REPORTERS_PATH=$CUSTOM_REPORTERS_PATH"
  echo "CUSTOM_METRICS_PATH=$CUSTOM_METRICS_PATH"

  echo
  echo "# METRICS"

  for metric in $__AVAILABLE_METRICS; do
    load_metric_with_prefix __m_${metric}_ ${metric}

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
    load_reporter_with_prefix __r_${reporter}_ ${reporter}

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
  echo ";DEFAULT_REPORTER=$DEFAULT_REPORTER"
  echo ";DEFAULT_METRICS=$DEFAULT_METRICS"
  echo ";CUSTOM_REPORTERS_PATH=$CUSTOM_REPORTERS_PATH"
  echo ";CUSTOM_METRICS_PATH=$CUSTOM_METRICS_PATH"

  for metric in $__AVAILABLE_METRICS; do
    load_metric_with_prefix __m_${metric}_ ${metric}

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
    load_reporter_with_prefix __r_${reporter}_ ${reporter}

    if is_function __r_${reporter}_defaults; then
      __r_${reporter}_defaults
    fi

    echo
    echo ";[reporter $reporter]"
    if is_function __r_${reporter}_docs; then
      print_prefixed ";" "$(__r_${reporter}_docs)"
    fi
  done
}