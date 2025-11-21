#!/bin/bash

set -m

PathToFile="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd $PathToFile

(mkdir output) 2>/dev/null

read -p "Type host for scan: " HOST
read -p "Type first port in range: " RANGE_ST
read -p "Type last port in range: " RANGE_FIN

RANGE=$((RANGE_FIN - RANGE_ST))

echo "Type maximum parallel threads ( more = faster = more CPU load )"
echo "Press ENTER to leave default value (50)"
read -p "Max parallel threads: "
if [[ "$MAX_JOBS" == "" ]]; then
  MAX_JOBS=50
fi

datestamp=$(date +%d-%m-%Y-%H:%M:%S)

echo "==================================" >> output/port-scanner-${HOST}-${datestamp}.txt
echo "       PORT CHECKER START         " >> output/port-scanner-${HOST}-${datestamp}.txt
echo " RANGE: FROM ${RANGE_ST} TO ${RANGE_FIN}"
echo "==================================" >> output/port-scanner-${HOST}-${datestamp}.txt

check_tcp(){
( echo > /dev/tcp/"$HOST"/"$PORT" ) 2>/dev/null & pid=$!
sleep 1s
if kill -0 "$pid" 2>/dev/null; then
  kill "$pid" 2>/dev/null || true
  wait "$pid" 2>/dev/null || true
#  echo "$HOST:$PORT tcp timed out"
  return 1
else
  echo "$HOST:$PORT TCP packet sent" >> output/port-scanner-${HOST}-${datestamp}.txt
  return 0
fi
}

(
for ((i=0; i<=$RANGE; i++)); do
  PORT=$((i + RANGE_ST))
  check_tcp &
  while (( $MAX_JOBS <= $(jobs -r | wc -l) )); do
    sleep 0.1
  done
done

wait

echo "==================================" >> output/port-scanner-${HOST}-${datestamp}.txt
echo "        PORT CHECKER DONE         " >> output/port-scanner-${HOST}-${datestamp}.txt
echo "==================================" >> output/port-scanner-${HOST}-${datestamp}.txt

) &
echo $! > output/port-scanner-pid

echo "Scanner started in background (PID $$)."
