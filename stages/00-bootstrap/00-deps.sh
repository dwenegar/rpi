#!/bin/bash

set -e

info "Checking dependencies"

readonly dependencies=(apt-cacher-ng qemu-user-static debootstrap rsync whois)

declare missing_dependencies=()
for dependency in "${dependencies[@]}"; do
	if ! dpkg --status "$dependency" &>/dev/null; then
		info "  $dependency: missing"
		missing_dependencies+=($dependency)
	else
		info "  $dependency: ok"
	fi
done

if [ ${#missing_dependencies[*]} -gt 0 ]; then
	info "Installing missing packages"
	apt-get install -y ${missing_dependencies[*]}
fi
