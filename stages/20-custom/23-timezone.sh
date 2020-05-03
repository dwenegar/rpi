#!/bin/bash

set -e

generate_debconf() {
	local -r area=${TIMEZONE%/*}
	local -r zone=${TIMEZONE#*/}
	echo "tzdata tzdata/Areas select $area"
	echo "tzdata tzdata/Zones/$area select $zone"
}

in_target debconf-set-selections -v <<-EOF
	$(generate_debconf)
EOF

in_target bin/bash <<-EOF
	rm -f /etc/timezone /etc/localtime
	dpkg-reconfigure tzdata
EOF
