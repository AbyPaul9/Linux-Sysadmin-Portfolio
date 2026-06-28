#!/bin/bash

while true; do
	disk=$(df -h / | awk 'NR==2 {print $5}' | tr -d '%')

	if [ $disk -gt 80 ]; then
		echo "WARNING: disk usage is at ${disk}%" >> /var/log/disk-monitor.log
	fi
	sleep 60
done
