#!/bin/sh

# config
INTERVAL=2
REPORTER=stdout # TODO: handle multiple reporters

# env
LC_ALL=en_US.UTF-8
LANG=en_US.UTF-8
LANGUAGE=en_US.UTF-8

# handle opts
opts_spec=":dhvr:i:"
opt_docs=false
opt_verbose=false

usage () {
  echo "Usage: $0 [-d] [-h] [-v] [-r reporter] [-i interval]"
}

help () {
  echo "TODO"
}

while getopts "$opts_spec" opt; do
  case "${opt}" in
    d)
      opt_docs=true
      ;;
    h)
      help
      exit
      ;;
    v)
      opt_verbose=true
      ;;
    r)
      REPORTER=$OPTARG
      ;;
    i)
      INTERVAL=$OPTARG
      ;;
    *)
      usage
      exit 1
      ;;
  esac
done
shift $((OPTIND-1))


# run
source ./lib/main.sh

if [ $opt_verbose = "true" ]; then
  verbose_on
  verbose "Started in verbose mode"
fi
verbose "OS detected: $OS_TYPE"

main_load
verbose "Metrics loaded: ${__METRICS[@]}"
verbose "Reporters loaded: ${REPORTER}"

if [ "$opt_docs" = true ]; then
  main_docs
  exit
fi

main_init
verbose "Metrics initialized"

verbose "Collecting metrics every $INTERVAL second(s)"
main_collect