is_number () {
  [ ! -z "$1" ] && printf '%f' "$1" &>/dev/null
}

iso_date () {
  date -u +"%Y-%m-%dT%H:%M:%SZ"
}