#!/bin/sh

# env
LC_ALL=en_US.UTF-8
LANG=en_US.UTF-8
LANGUAGE=en_US.UTF-8
DIR=$(dirname "$0")

usage () {
  echo "  Usage: $0 [-d] [-h] [-v] [-c] [-m] [-r] [-i] [-C] [-u]"
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
  echo "    -C, --print-config         print output to be used in a config file"
  echo "    -u, --update               pull the latest version (requires git)"
  echo "    -d, --docs                 show documentation"
  echo "    -h, --help                 show this text"
  echo
}

# handle opts
opt_config_file=
opt_metrics=
opt_reporter=
opt_interval=
opt_verbose=false
opt_print_config=false
opt_do_update=false
opt_docs=false

while [ $# -gt 0 ]; do
  case $1 in
    -c|--config)
      shift
      opt_config_file=$1
      ;;

    -m|--metrics)
      shift
      opt_metrics=$1
      ;;

    -r|--reporter)
      shift
      opt_reporter=$1
      ;;

    -i|--interval)
      shift
      opt_interval=$1
      ;;

    -v|--verbose)
      opt_verbose=true
      ;;

    -C|--print-config)
      opt_print_config=true
      ;;

    -u|--update)
      opt_do_update=true
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
. ${DIR}/lib/main.sh

if [ $opt_do_update = true ]; then
  if ! command_exists git; then
    echo "Error: --update requires 'git' to be in the PATH"
    exit 1
  fi
  echo "Fetching latest version..."
  git pull https://github.com/pstadler/metrics.sh.git master
  exit $?
fi

if [ $opt_verbose = true ]; then
  verbose_on
  verbose "Started in verbose mode"
  verbose "OS detected: $OS_TYPE"
fi

main_load
verbose "Available metrics: $__AVAILABLE_METRICS"
verbose "Available reporters: $__AVAILABLE_REPORTERS"

if [ $opt_docs = true ]; then
  main_print_docs
  exit
fi

if [ $opt_print_config = true ]; then
  main_print_config
  exit
fi

if [ -n "$opt_config_file" ]; then
  verbose "Loading configuration file: $opt_config_file"

  parse_config "$opt_config_file"
  if [ $? -ne 0 ]; then
    exit 1
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

# --reporter always wins
if [ -n "$opt_reporter" ]; then
  REPORTER=$opt_reporter
fi

# --metrics always wins
if [ -n "$opt_metrics" ]; then
  METRICS=$opt_metrics
fi

# --interval always wins
if [ -n "$opt_interval" ]; then
  INTERVAL=$opt_interval
fi

main_init "$METRICS" "$REPORTER"
verbose "Using metrics: $__METRICS"
verbose "Using reporter: $__REPORTER"

echo "metrics.sh started with PID: $$"
verbose "Collecting metrics every $INTERVAL second(s)"
main_collect
