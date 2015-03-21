#!/bin/sh

# config
INTERVAL=2
REPORTER=stdout
METRICS=cpu,disk_io,disk_usage,heartbeat,memory,network_io,swap
CONFIG_FILE=

# env
LC_ALL=en_US.UTF-8
LANG=en_US.UTF-8
LANGUAGE=en_US.UTF-8

usage () {
  echo "  Usage: $0 [-d] [-h] [-v] [-m metrics] [-r reporter] [-i interval]"
}

help () {
  echo
  usage
  echo
  echo "  Options: "
  echo
  echo "    -c, --config   <file>      path to config file"
  echo "    -m, --metrics  <metrics>   comma-separated list of metrics to collect"
  echo "    -r, --reporter <reporter>  use specified reporter (default: stdout)"
  echo "    -i, --interval <seconds>   collect metrics every n seconds (default: 2)"
  echo "    -v, --verbose              enable verbose mode"
  echo "    -d, --docs                 show documentation"
  echo "    -h, --help                 show this text"
  echo
}

# handle opts
opt_docs=false
opt_verbose=false

while [ $# -gt 0 ]; do
  case $1 in
    -c|--config)
      shift
      CONFIG_FILE=$1
      ;;

    -m|--metrics)
      shift
      METRICS=$1
      ;;

    -r|--reporter)
      shift
      REPORTER=$1
      ;;

    -i|--interval)
      shift
      INTERVAL=$1
      ;;

    -v|-verbose)
      opt_verbose=true
      ;;

    -d|--docs)
      opt_docs=true
      ;;

    -h|--help)
      help
      exit
      ;;

    *)
      usage
      exit 1
      ;;
  esac

  shift
done

# run
. ./lib/main.sh

if [ $opt_verbose = "true" ]; then
  verbose_on
  verbose "Started in verbose mode"
fi
verbose "OS detected: $OS_TYPE"

main_load
verbose "Available metrics: $__AVAILABLE_METRICS"
verbose "Available reporters: $__AVAILABLE_REPORTERS"

if [ $opt_docs = true ]; then
  main_docs
  exit
fi

if [ -n "$CONFIG_FILE" ]; then
  verbose "Loading configuration file: $CONFIG_FILE"

  parse_config $CONFIG_FILE
  if [ $? -ne 0 ]; then
    exit 1
  fi

  if is_function global_config; then
    global_config
  fi

  configured_reporters=$(get_configured_reporters)
  if [ -n "$configured_reporters" ]; then
    REPORTER=$configured_reporters
  fi

  configured_metrics=$(get_configured_metrics)
  if [ -n "$configured_metrics" ]; then
    METRICS=$configured_metrics
  fi
fi

main_init "$METRICS" "$REPORTER"
verbose "Using metrics: $__METRICS"
verbose "Using reporter: $__REPORTER"

verbose "Collecting metrics every $INTERVAL second(s)"
main_collect