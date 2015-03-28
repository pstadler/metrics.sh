#!/bin/sh
### BEGIN INIT INFO
# Provides:          metrics.sh
# Required-Start:    $local_fs $network $named $time $syslog
# Required-Stop:     $local_fs $network $named $time $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Start and stop metrics.sh
# Description:       Controls the metrics daemon "metrics.sh"
### END INIT INFO

SCRIPT_DIR=/opt/metrics.sh
CONFIG_FILE=/etc/metrics.sh/metrics.ini
RUNAS=root
SCRIPT=$SCRIPT_DIR/metrics.sh
ARGS="-c $CONFIG_FILE"
NAME=metrics.sh

PIDFILE=/var/run/$NAME.pid
LOGFILE=/var/log/$NAME.log

# Exit if the package is not installed
[ -x "$SCRIPT" ] || exit 0

cd $SCRIPT_DIR

start() {
  PID=$([ -f $PIDFILE ] && cat $PIDFILE)
  if [ -n "$PID" ] && kill -0 $PID; then
    echo 'Service already running' >&2
    return 1
  fi
  echo 'Starting service...' >&2
  local CMD="$SCRIPT $ARGS &> \"$LOGFILE\" & echo \$!"
  su -c "$CMD" $RUNAS > "$PIDFILE"
  echo 'Service started' >&2
}

stop() {
  if [ ! -f "$PIDFILE" ] || ! kill -0 $(cat "$PIDFILE"); then
    echo 'Service not running' >&2
    return 1
  fi
  echo 'Stopping service...' >&2
  kill -15 $(cat "$PIDFILE") && rm -f "$PIDFILE"
  echo 'Service stopped' >&2
}

status() {
  if [ -f $PIDFILE ]; then
    PID=$(cat $PIDFILE)
    if [ -z "$(ps axf | grep $PID | grep -v grep)" ]; then
      echo "The process appears to be dead but pidfile still exists"
    else
      echo "Service is running"
    fi
  else
    echo "Service not running"
  fi
}

case "$1" in
  start)
    start
    ;;
  stop)
    stop
    ;;
  status)
    status
    ;;
  *)
    echo "Usage: $0 {start|stop|status}"
esac
