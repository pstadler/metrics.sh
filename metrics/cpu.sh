#!/bin/sh

collect () {
  echo $(ps aux | awk {'sum+=$3;print sum'} | tail -n 1)
}