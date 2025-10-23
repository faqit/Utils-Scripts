#!/bin/bash

set -euo pipefail

TIMEOUT=2
SLEEP_TIMER=0.5
PROTOCOL="tcp"

usage(){
cat <<EOF
Usage: $0 <optionals> host port1 <port2 port3..>
Optionals: [-t timeout] [-s sleep between knocks] [-p tcp/udp]
Defaults: timeout=${TIMEOUT}s, sleep=${SLEEP_TIMER}s, protocol=${PROTOCOL}
EOF
exit 1
}
#check arguments
if [ $# -lt 2 ]; then usage; fi

#parsing arguments
while getopts ":t:s:p:" opt; do
  case $opt in
    t) TIMEOUT="$OPTARG" ;;
    s) SLEEP_TIMER="$OPTARG" ;;
    p) PROTOCOL="$OPTARG" ;;
    *) usage ;;
  esac
done
shift $((OPTIND-1)) #host become $1 instead of $5

HOST="$1"; shift
PORTS=("$@")

knock_tcp(){
local host=$1 port=$2 timeout=$3
( echo > /dev/tcp/"$host"/"$port" ) 2>/dev/null & pid=$!
echo Knocking $host:$port
sleep "$timeout"
if kill -0 "$pid" 2>/dev/null; then
  kill "$pid" 2>/dev/null || true
  wait "$pid" 2>/dev/null || true
  echo "$host:$port tcp timed out"
fi
}

knock_udp(){
local host=$1 port=$2
(echo -n) > /dev/udp/"$host"/"$port" 2>/dev/null || true
echo "$host:$port UDP packet sent"
}

echo "Started knocking ${HOST} with ${PROTOCOL^^} sequence: ${PORTS[*]}"
for i in "${PORTS[@]}"; do
  if [ "$PROTOCOL" = "tcp" ]; then
    knock_tcp "$HOST" "$i" "$TIMEOUT"
  else
    knock_udp "$HOST" "$i"
  fi
  sleep "$SLEEP_TIMER"
done

echo "Knocking complete"
