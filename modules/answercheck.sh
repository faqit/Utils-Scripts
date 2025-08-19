#!/bin/bash

while true; do
    read -p "(Y)es/(N)o: " PARAM
    PARAM=${PARAM,,}
    if [[ "$PARAM" == "yes" || "$PARAM" == "y" ]]; then
        echo "Answer - YES"
        break
    elif [[ "$PARAM" == "no" || "$PARAM" == "n" ]]; then
        echo "Answer - NO"
        break
    else
        echo "Incorrect input, Type (Y)es/(N)o"
    fi
done
