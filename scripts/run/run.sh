if [ $# -ne 3 ]; then
  echo "Usage: run <SERVERNAME> <PAS/PUB> <COMMAND>"
  echo "For SERVERNAME look at SERVERNAMES file (should be in the same directory)"
  exit 1
fi

PathToFile="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

filename="${PathToFile}/SERVERNAMES"

SERVERNAME=$1

ConnType=$2
ConnType=${ConnType,,}

COMMAND=$3
port=22
pubkey=/home/user/ssh/pubkey

while IFS= read -r line; do
    server="${line%%=*}"
    value="${line#*=}"

    if [[ "$server" == "$SERVERNAME" ]]; then
        user_ip="${value%%:*}"

        user="${user_ip%@*}"
        ip="${user_ip#*@}"
    fi

done < "$filename"

ConnectionKey="ssh ${user}@${ip} -p ${port} -i ${pubkey}"
ConnectionPass="sshpash -p ${password} ssh ${user}@${ip} -p ${port} -o StrictHostKeyChecking=no"

while true; do
  if [[ "$ConnType" == "pas"  ]]; then
    read -p "Type password: " password
    $ConnectionPass $COMMAND
    break
  elif [[ "$ConnType" == "pub" ]]; then
    $ConnectionKey $COMMAND
    break
  else
    echo "Type PAS or PUB"
  fi
done
