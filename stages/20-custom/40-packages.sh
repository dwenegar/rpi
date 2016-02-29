#!/bin/bash

set -e

if [ -n "$EXTRA_PACKAGES" ]; then
	in_target apt-get install -y $EXTRA_PACKAGES
fi
