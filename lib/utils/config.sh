#!/bin/sh

__CFG_REPORTERS=
__CFG_METRICS=

get_configured_reporters () {
  echo $__CFG_REPORTERS
}

get_configured_metrics () {
  echo $__CFG_METRICS
}

parse_config () {
  if [ ! -f "$1" ]; then
    echo "Error: unable to load config file: ${1}"
    return 1
  fi

  RESTORE_IFS=$IFS
  # dash compatibility :-(
  IFS=$'
'

  local _group
  local _name
  local _alias
  local _body

  end_section () {
    if [ -z "$_group" ]; then
      return
    fi

    local fn_name
    if [ "$_group" = "reporter" ]; then
      __CFG_REPORTERS=$(trim "${__CFG_REPORTERS} ${_name}:${_alias}")
      fn_name="__r_"
    elif [ "$_group" = "metric" ]; then
      __CFG_METRICS=$(trim "${__CFG_METRICS} ${_name}:${_alias}")
      fn_name="__m_"
    else
      fn_name="global"
    fi

    if [ -n "$_alias" ]; then
      fn_name="${fn_name}${_alias}"
    elif [ -n "$_name" ]; then
      fn_name="${fn_name}${_name}"
    fi

    if [ -z "$_body" ]; then
      return
    fi

    #echo "${fn_name}_config () { ${_body}; }"
    eval "${fn_name}_config () { ${_body}; }"
  }

  for line in $(cat $1); do
    # handle comments / empty lines
    line=$(echo $line | grep -v '^\(#\|;\)')

    if [ -z "$line" ]; then
      continue
    fi

    local _section=$(echo $line | grep '^\[.*' | sed 's/\[\(.*\)\]/\1/')
    if [ -n "$_section" ]; then
      end_section
      unset _group _name _alias _body

      _group=$(echo $_section | awk '{ print $1 }')

      if echo " metrics.sh metric reporter " | grep -q -v " $_group "; then
        echo "Warning: unknown section in configuration file: $_section"
        continue
      fi

      if [ "$_group" = "metrics.sh" ]; then
        _group="global"
        continue
      fi

      _section=$(echo $_section | awk '{ print $2 }')
      _name=$(echo $_section | awk 'BEGIN { FS=":" } { print $1 }')
      _alias=$(echo $_section | awk 'BEGIN { FS=":" } { print $2 }')
      continue
    fi

    _body=$(echo "${_body};${line}" | sed 's/^;//g')
  done

  end_section

  IFS=$RESTORE_IFS
}

get_name () {
  echo $1 | awk 'BEGIN { FS=":" } { print $1 }'
}

get_alias () {
  local _alias=$(echo $1 | awk 'BEGIN { FS=":" } { print $2 }')
  if [ -z "$_alias" ]; then
    _alias=$(echo $1 | awk 'BEGIN { FS=":" } { print $1 }')
  fi
  echo $_alias
}