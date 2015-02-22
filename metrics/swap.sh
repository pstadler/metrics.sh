#!/bin/sh

if [ $OS_TYPE == "osx" ]; then

  collect () {
    echo $(sysctl -n vm.swapusage | awk '{printf "%.2f", $6 / $3 * 100.0}')
  }

else

  collect () {
    echo $(free | awk '/Swap/{printf "%.2f", $3/$2 * 100.0;}')
  }

fi