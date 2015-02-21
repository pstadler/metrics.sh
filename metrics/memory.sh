#!/bin/sh

collect () {
  echo $(free | awk '/buffers\/cache/{print $4/($3+$4) * 100.0;}')
}