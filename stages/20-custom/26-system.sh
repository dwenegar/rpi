#!/bin/bash

set -e

if [ "$ENABLE_WATCHDOG" == "true" ]; then
	copy_file /etc/modules-load.d/rpi-watchdog.conf
	copy_file /etc/systemd/system.conf.d/rpi-watchdog.conf
fi
