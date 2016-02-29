#!/bin/bash

set -e

readonly raspberrypi_archive="https://archive.raspberrypi.org/debian"
readonly raspberrypi_archive_key="raspberrypi.gpg.key"
readonly raspberrypi_archive_key_sha256="CF8A1AF502A2AA2D763BAE7E82B129927FA3303E"

readonly output="$BUILD_DIR/$raspberrypi_archive_key"
curl -# -o $output $raspberrypi_archive/$raspberrypi_archive_key
if [ "$(gpg $output | grep -c ^pub)" -gt 1 ]; then
	fail "More than one raspberrypi_archive_key in $output"
fi
if [ "$(gpg --with-fingerprint --with-colons $output | grep ^fpr: | awk -F: '{print $10}')" != "$raspberrypi_archive_key_sha256" ]; then
	fail "Invalid hash for $output"
fi

in_target apt-key add - < "$output"

copy_file /etc/apt/sources.list
copy_file /etc/apt/sources.list.d/rpi.list
copy_file /etc/apt/apt.conf.d/50rpi-pdiff

in_target bin/bash -x <<-EOF
	http_proxy=http://localhost:3142 apt-get update
EOF
