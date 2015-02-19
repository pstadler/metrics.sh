#!/bin/sh

for script in $(find ./metrics -type f -name '*.sh'); do
  sh $script
done