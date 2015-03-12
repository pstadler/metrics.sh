#!/bin/sh

if is_osx; then
  collect () {
    report $(sysctl -n vm.swapusage |
              awk '{ if (int($3) == 0) exit; printf "%.1f", $6 / $3 * 100.0 }')
  }
else
  collect () {
    report $(free |
        awk '/Swap/{ if (int($2) == 0) exit; printf "%.1f", $3 / $2 * 100.0 }')
  }
fi

docs () {
  echo "Percentage of used swap space."
}