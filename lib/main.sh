# load utils
for util in ./lib/utils/*.sh; do source $util; done

# init
__METRICS=()


main_load () {
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
}

main_init () {
  TEMP_DIR=$(make_temp_dir)

  # register trap
  trap '
    main_terminate
    trap - SIGTERM && kill -- -$$ SIGINT SIGTERM EXIT
  ' SIGINT SIGTERM EXIT

  # init reporter
  if is_function __r_${REPORTER}_init; then
    __r_${REPORTER}_init
  fi

  # init metrics
  for metric in ${__METRICS[@]}; do
    if ! is_function __m_${metric}_init; then
      continue
    fi

    __m_${metric}_init
  done
}

main_collect () {
  # used by metrics to return results
  report () {
    local _r_result
    if [ -z $2 ]; then
      _r_label=$metric
      _r_result="$1"
    else
      _r_label="$metric.$1"
      _r_result="$2"
    fi
    if is_number $_r_result; then
      __r_${REPORTER}_report $_r_label $_r_result
    fi
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
}

main_terminate () {
  # terminate metrics
  for metric in ${__METRICS[@]}; do
    if ! is_function __m_${metric}_terminate; then
      continue
    fi
    __m_${metric}_terminate
  done

  # terminate reporter
  if is_function __r_${REPORTER}_terminate; then
    __r_${REPORTER}_terminate
  fi

  # delete temporary directory
  if [ ! -z $TEMP_DIR ] && [ -d $TEMP_DIR ]; then
    rmdir $TEMP_DIR
  fi
}

main_docs () {
  echo "Available metrics:"
  for metric in ${__METRICS[@]}; do
    if ! is_function __m_${metric}_docs; then
      continue
    fi

    echo "[$metric]"
    __m_${metric}_docs
    echo
  done
}