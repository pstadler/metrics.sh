#!/bin/sh

defaults () {
  if [ -z $NETWORK_IO_INTERFACE ]; then
    if is_osx; then
      NETWORK_IO_INTERFACE="en0"
    else
      NETWORK_IO_INTERFACE="eth0"
    fi
  fi
}

start () {
  readonly divisor=$(($INTERVAL * 1024))

  if is_osx; then
    get_sample () {
      netstat -b -I $NETWORK_IO_INTERFACE | awk '{ print $7" "$10 }' | tail -n 1
    }
  else
    get_sample () {
      cat /proc/net/dev | awk -v iface_regex="$NETWORK_IO_INTERFACE:" \
                                      '$0 ~ iface_regex { print $2" "$10 }'
    }
  fi

  calc_kBps() {
    echo $1 $2 | awk -v divisor=$divisor \
                '{ printf "%.2f", ($1 - $2) / divisor }'
  }
}

collect () {
  local sample
  sample=$(get_sample)
  if [ ! -z "$previous_sample" ]; then
    report "in" $(calc_kBps $(echo $sample | awk '{print $1}') \
                                $(echo $previous_sample | awk '{print $1}'))
    report "out" $(calc_kBps $(echo $sample | awk '{print $2}') \
                                $(echo $previous_sample | awk '{print $2}'))
  fi
  previous_sample="$sample"
}

docs () {
  echo "Network traffic in kB/s."
  echo "NETWORK_IO_INTERFACE=$NETWORK_IO_INTERFACE"
}