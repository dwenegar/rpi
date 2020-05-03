#!/bin/bash

set -euo pipefail

DEBUG=${DEBUG:-}

if [ -n "$DEBUG" ]; then
	set -x
fi

if [ "$(id -u)" != "0" ]; then
	echo "This script must be run as root"
	exit 1
fi

source scripts/logging.sh
export -f info
export -f error
export -f fail

source scripts/config.sh
source scripts/mount.sh

export BUILD_DIR="$(pwd)/build"
export GNUPGHOME="$BUILD_DIR/gnupg"

export TARGET=""
export PREVIOUS_TARGET=""

## Apt
export MIRROR=https://mirrordirector.raspbian.org/raspbian
export DIST=jessie
export NO_RECOMMENDS=false

## Root
export DISABLE_ROOT=false
export ROOT_PASSWORD=root
export ROOT_SSH_PUBKEY=

## Custom user
export USER_FULLNAME=
export USER_NAME=pi
export USER_PASSWORD=raspberry
export USER_SSH_PUBKEY=
export USER_IS_SUDOER=true

## Network
export INTERFACE=eth0
export HOSTNAME=raspberrypi
export OTHER_HOSTNAMES=
export DOMAIN_NAME=
export IP_ADDRESS=dhcp
export IP_GATEWAY=
export IP_NAMESERVERS=

## Locales
export LOCALE="en_US.UTF-8"

## Timezone
export TIMEZONE=

## Hardware
export ENABLE_WATCHDOG=false

export REDUCE=true

in_target() {
	LANG=C \
		LC_ALL=C \
		DEBIAN_FRONTEND=noninteractive \
		chroot "$TARGET" "$@"
}

copy_file() {
	local -r src="$1"
	local -r target="${2:-$1}"

	[ -f "files/$src" ] || return 1

	if [ -d "$TARGET/$target" ]; then
		target="$target/${target##*/}"
	fi

	mkdir -p "$TARGET/$(dirname $target)"
	cp --preserve=mode -v "files/$src" "$TARGET/$target"
}

copy_dir() {
	local -r src="$1"
	local -r target="${2:-$1}"

	[ -d "files/$src" ] || return 1

	mkdir -p "$TARGET/$(dirname $target)"
	cp -a --preserve=mode -v "files/$src/" "$TARGET/$target/"
}

export -f in_target
export -f copy_file
export -f copy_dir

read_package_list() {
	local -r file="$1"
	local -a packages=()
	while read package; do
		if [ -n "$package" ] && [ "${package:0:1}" != "#" ]; then
			packages+=($package)
		fi
	done <$file
	echo "${packages[@]}"
}

run_step() {
	local -r step="$1"

	info "#### STEP $step"
	case $step in
	*-debconf)
		info "Setting debconf selections"
		in_target debconf-set-selections -v <<-EOF
			$(cat $step)
		EOF
		;;
	*-packages-nr)
		packages=$(read_package_list $step)
		info "Installing packages $packages (no recommends)"
		in_target bin/bash <<-EOF
			http_proxy=http://localhost:3142 \
			                        				        					apt-get install -y --no-install-recommends $packages
			          EOF
			  ;;
			 *-packages)
			  packages=$(read_package_list $step)
			  info "Installing packages $packages"
			  in_target bin/bash <<-EOF
			http_proxy=http://localhost:3142    \
			                                                                         apt-get install -y $packages
		EOF
		;;
	*-source)
		info "Sourcing $step"
		source "$step"
		;;
	*)
		if [ -x $step ]; then
			info "Executing $step"
			./$step
		fi
		;;
	esac
}

run_stage() {
	local -r stage="$1"
	local -r tag="$BUILD_DIR/.$(basename $TARGET)"

	info "### STAGE $stage (tag: $tag)"

	if [ ! -f "$tag" ]; then

		mkdir -p "$TARGET"

		if [ -n "$PREVIOUS_TARGET" ] && [ -d "$PREVIOUS_TARGET" ]; then
			info "Syncing $TARGET with $PREVIOUS_TARGET"
			rsync --archive --delete "$PREVIOUS_TARGET/" "$TARGET/"
		fi

		pushd "$stage" &>/dev/null

		local -r steps="$(cat series)"
		for step in $steps; do
			if [ -f "$step" ]; then
				run_step "$step"
			fi
		done

		popd &>/dev/null

		touch "$tag"
	fi
}

run_stages() {
	local -r stages_dir="$1"
	if [ -d "$stages_dir" ]; then

		pushd "$stages_dir" &>/dev/null

		local -r stages="$(cat series)"
		for stage in $stages; do
			if [ -d "$stage" ]; then
				TARGET="$BUILD_DIR/${stage/custom/$build_id}"
				(run_stage "$stage")
				PREVIOUS_TARGET="$TARGET"
			fi
		done

		popd &>/dev/null
	fi
}

main() {
	local -r build_id="${1:-}"
	if [ -z "$build_id" ]; then
		echo "You must provide a build id"
		exit 1
	fi

	local -r config="config.$build_id"
	load_config "$config"
	sanitize_config
	verify_config
	show_config

	run_stages stages
	run_stages stages-custom/$build_id
}

main "$@"
