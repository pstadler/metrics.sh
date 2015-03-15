#!/bin/sh

load_metric_with_prefix () {
  local prefix=$1
  local file=$2

  local content=$(sed \
          -e "s/^[[:space:]]*\(init[ ]*()[ ]*{\)/${prefix}\1/" \
          -e "s/^[[:space:]]*\(collect[ ]*()[ ]*{\)/${prefix}\1/" \
          -e "s/^[[:space:]]*\(terminate[ ]*()[ ]*{\)/${prefix}\1/" \
          -e "s/^[[:space:]]*\(docs[ ]*()[ ]*{\)/${prefix}\1/" $file)

  eval "$content"
}

load_reporter_with_prefix () {
  local prefix=$1
  local file=$2
  local content=$(sed \
          -e "s/^[[:space:]]*\(init[ ]*()[ ]*{\)/${prefix}\1/" \
          -e "s/^[[:space:]]*\(report[ ]*()[ ]*{\)/${prefix}\1/" \
          -e "s/^[[:space:]]*\(terminate[ ]*()[ ]*{\)/${prefix}\1/" \
          -e "s/^[[:space:]]*\(docs[ ]*()[ ]*{\)/${prefix}\1/" $file)

  eval "$content"
}