#!/bin/sh

load_reporter_with_prefix () {
  local prefix=$1
  local file=$2
  local content

  content=$(sed \
          -e 's/^[[:space:]]*\(defaults[ ]*()[ ]*{\)/'"$prefix"'\1/' \
          -e 's/^[[:space:]]*\(start[ ]*()[ ]*{\)/'"$prefix"'\1/' \
          -e 's/^[[:space:]]*\(report[ ]*()[ ]*{\)/'"$prefix"'\1/' \
          -e 's/^[[:space:]]*\(stop[ ]*()[ ]*{\)/'"$prefix"'\1/' \
          -e 's/^[[:space:]]*\(docs[ ]*()[ ]*{\)/'"$prefix"'\1/' $file)

  eval "$content"
}

load_metric_with_prefix () {
  local prefix=$1
  local file=$2
  local content

  # dash will error if this variable is defined as `local`
  content=$(sed \
          -e 's/^[[:space:]]*\(defaults[ ]*()[ ]*{\)/'"$prefix"'\1/' \
          -e 's/^[[:space:]]*\(start[ ]*()[ ]*{\)/'"$prefix"'\1/' \
          -e 's/^[[:space:]]*\(collect[ ]*()[ ]*{\)/'"$prefix"'\1/' \
          -e 's/^[[:space:]]*\(stop[ ]*()[ ]*{\)/'"$prefix"'\1/' \
          -e 's/^[[:space:]]*\(docs[ ]*()[ ]*{\)/'"$prefix"'\1/' $file)

  eval "$content"
}
