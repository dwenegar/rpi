#!/bin/bash

set -e

touch "$TARGET/spindle_install"
in_target bin/bash <<-EOF
	http_proxy=http://localhost:3142 apt-get install -y  raspi-copies-and-fills
EOF
