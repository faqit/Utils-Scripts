#!/bin/bash

echo "Creating rules for journalctl"
sudo journalctl --vacuum-size=500M
sudo journalctl --vacuum-time=7d
echo "Now interval - 7 days, max-size 500M"

echo "Clearing nginx&apache logs"
sudo find /var/log/apache2/ -type f -name "*.log" | sort | head -n -5 | xargs -r sudo rm -f
sudo find /var/log/nginx/ -type f -name "*.log" | sort | head -n -5 | xargs -r sudo rm -f

echo "Cleaning archived logs"
sudo rm -rf /var/log/*.gz
