VERBOSE_MODE=false

verbose_on () {
  VERBOSE_MODE=true
}

verbose_off () {
  VERBOSE_MODE=true
}

verbose () {
  if [ $VERBOSE_MODE = "false" ]; then
    return
  fi
  echo "$@"
}