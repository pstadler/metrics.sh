#!/bin/sh

load_metric_with_prefix () {
  local prefix=$1
  local file=$2

  local content=$(sed \
          -e "s/^\s*\(init[ ]*()[ ]*{\)/${prefix}\1/" \
          -e "s/^\s*\(collect[ ]*()[ ]*{\)/${prefix}\1/" \
          -e "s/^\s*\(terminate[ ]*()[ ]*{\)/${prefix}\1/" \
          -e "s/^\s*\(docs[ ]*()[ ]*{\)/${prefix}\1/" $file)

  eval "$content"
}

load_reporter_with_prefix () {
  local prefix=$1
  local file=$2
  local content=$(sed \
          -e "s/^\s*\(init[ ]*()[ ]*{\)/${prefix}\1/" \
          -e "s/^\s*\(report[ ]*()[ ]*{\)/${prefix}\1/" \
          -e "s/^\s*\(terminate[ ]*()[ ]*{\)/${prefix}\1/" \
          -e "s/^\s*\(docs[ ]*()[ ]*{\)/${prefix}\1/" $file)

  eval "$content"
}