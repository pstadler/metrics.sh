#!/bin/sh

defaults () {
  if [ -z $PROMETHEUS_PORT ]; then
    PROMETHEUS_PORT=9100
  fi
  if [ -z $PROMETHEUS_METRIC_NAME ]; then
    PROMETHEUS_METRIC_NAME="metrics_sh"
  fi
}

start () {
  readonly prometheus_report_header="# TYPE metrics_sh gauge"
  readonly prometheus_stats_file=$TEMP_DIR/$(unique_id)_prometheus
  readonly prometheus_httpd_fifo=$TEMP_DIR/$(unique_id)_prometheus_fifo
  touch $prometheus_stats_file
  mkfifo $prometheus_httpd_fifo

  prometheus_httpd &
  prometheus_stats_file_monitor &
}

report () {
  local metric=$1
  local value=$2

  printf "%s{metric=\"%s\"} %s %s\n" "$PROMETHEUS_METRIC_NAME" "$metric" \
          "$value" "$(unix_timestamp)000" >> $prometheus_stats_file
}

stop () {
  if [ ! -z $prometheus_stats_file ] && [ -f $prometheus_stats_file ]; then
    rm $prometheus_stats_file
  fi
  if [ ! -z $prometheus_httpd_fifo ] && [ -p $prometheus_httpd_fifo ]; then
    rm $prometheus_httpd_fifo
  fi
}

prometheus_httpd () {
  echo "Serving prometheus HTTP endpoint at http://localhost:$PROMETHEUS_PORT/metrics"
  while true; do
    local REQUEST RESPONSE
    cat $prometheus_httpd_fifo | nc -l $PROMETHEUS_PORT | while read line; do
      line=$(echo "$line" | tr -d '[\r\n]')
      # extract the request
      if echo "$line" | grep -qE '^GET /'; then
        REQUEST=$(echo "$line" | cut -d ' ' -f2)
      # end of request
      elif [ "x$line" = x ]; then
        if echo $REQUEST | grep -qE '^/metrics'; then
          RESPONSE=$(cat $prometheus_stats_file)
          # clear
          printf "" > $prometheus_stats_file
          printf "HTTP/1.1 200 OK\nContent-Type: text/plain\n\n%s\n%s\n" \
            "$prometheus_report_header" "$RESPONSE" > $prometheus_httpd_fifo
        else
          printf "HTTP/1.1 404 Not Found\nLocation: %s\n\n%s\n" \
                    "$REQUEST" "404 Not Found" > $prometheus_httpd_fifo
        fi
      fi
    done
  done
}

prometheus_stats_file_monitor () {
  while true; do
    local bytes=$(ls -l $prometheus_stats_file | awk '{ print $5 }')
    # clear file if bigger than 5MB
    if [ $bytes -gt 5000000 ]; then
      printf "" > $prometheus_stats_file
    fi
    sleep 120
  done
}

docs () {
  echo "Provide HTTP endpoint for Prometheus (http://prometheus.io)."
  echo "Exposes metrics of type gauges in the following format:"
  echo "$PROMETHEUS_METRIC_NAME{metric=\"<metric>\"} <value> <timestamp>"
  echo "PROMETHEUS_PORT=$PROMETHEUS_PORT"
  echo "PROMETHEUS_METRIC_NAME=$PROMETHEUS_METRIC_NAME"
}