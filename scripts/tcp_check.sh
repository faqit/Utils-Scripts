#!/bin/bash

usage() {
cat <<EOF
Usage: $0 -h <HOST> -p <PORT>
Optionals: [-t TIMEOUT(seconds)] [-r REPEATS]
Defaults:
  Timeout - 1 second
  Repeats - 5
EOF
exit 1
}

TIMEOUT=1
REPEATS=5
ERR=0
SUC=0

if [ $# -lt 2 ]; then usage; fi

while getopts ":h:p:t:r:" opt; do
  case $opt in
    h) HOST="$OPTARG" ;;
    p) PORT="$OPTARG" ;;
    t) TIMEOUT="$OPTARG" ;;
    r) REPEATS="$OPTARG" ;;
    *) usage ;;
  esac
done

if [ -z "$HOST" ] || [ -z "$PORT" ]; then
    usage
    exit 1
fi

check_tcp(){
( echo > /dev/tcp/"$HOST"/"$PORT" ) 2>/dev/null & pid=$!
sleep $TIMEOUT
if kill -0 "$pid" 2>/dev/null; then
  kill "$pid" 2>/dev/null || true
  wait "$pid" 2>/dev/null || true
  echo "$HOST:$PORT tcp timed out"
  return 1
else
  echo "$HOST:$PORT TCP packet sent"
  return 0
fi
}

echo "Check availability for $HOST:$PORT"
if [ "$TIMEOUT" != 1  ]; then
echo "Timeout for TCP connection is $TIMEOUT seconds"
fi
if [ "$REPEATS" != 1 ]; then
echo "Repeats $REPEATS times"
fi

for ((i=0;i<$REPEATS;i++)) do
  check_tcp
  if [ $? -eq 0 ]; then
    SUC=$(($SUC + 1))
  else
    ERR=$(($ERR + 1))
  fi
  sleep 0.25
done
RATE=$(awk "BEGIN {print 100 - $ERR*100/$REPEATS}")
echo "Port checking is done!"
echo "Recieved=$SUC, Lost=$ERR"
echo "Success rate is $RATE%"
