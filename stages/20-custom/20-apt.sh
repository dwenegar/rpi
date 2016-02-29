#!/bin/bash

set -e

if [ -n "$APT_PROXY" ]; then
	copy_file /etc/apt/apt.conf.d/50rpi-proxy
	sed "$TARGET/etc/apt/apt.conf.d/50rpi-proxy" -i -e "s|APT_PROXY|$APT_PROXY|"
fi

if [ "$NO_RECOMMENDS" = "true" ]; then
	copy_file /etc/apt/apt.conf.d/50rpi-norecommends
fi

if [ "$REDUCE" = "true" ]; then
	copy_file /etc/apt/apt.conf.d/50rpi-compress
	copy_file /etc/apt/apt.conf.d/50rpi-nocache
fi
