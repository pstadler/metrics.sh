#!/bin/sh

# config
INTERVAL=2
REPORTER=stdout

# env
LC_ALL=en_US.UTF-8
LANG=en_US.UTF-8
LANGUAGE=en_US.UTF-8

# handle opts
opts_spec=":dhvr:i:"
opt_docs=false
opt_verbose=false

usage () {
  echo "  Usage: $0 [-d] [-h] [-v] [-r reporter] [-i interval]"
}

help () {
  echo
  usage
  echo
  echo "  Options: "
  echo
  echo "    -r, --reporter <reporter>  use specified reporter (default: stdout)"
  echo "    -i, --interval <seconds>   collect metrics every n seconds (default: 2)"
  echo "    -v, --verbose              enable verbose mode"
  echo "    -d, --docs                 show documentation"
  echo "    -h, --help                 show this text"
  echo
}

while [ $# -gt 0 ]; do
  case $1 in
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