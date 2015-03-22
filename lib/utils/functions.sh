#!/bin/sh

# this is bad, but `declare -f -F` is not portable
is_function () {
  type $1 2> /dev/null | grep -q 'function$'
}

command_exists () {
  type $1 > /dev/null 2>&1
}
