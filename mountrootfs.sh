#!/bin/bash

set -eo pipefail

if [ "$(id -u)" != "0" ]; then
	echo "This script must be run as root"
	exit 1
fi

source scripts/logging
source scripts/mount

export TARGET=""

main()
{
	TARGET="$1"
	if [ -z "$TARGET" ]; then
		echo "You must provide a TARGET"
		exit 1
	fi

	if [ -f $TARGET/etc/ld.so.preload ]; then
		mv $TARGET/etc/ld.so.preload $TARGET/etc/ld.so.preload.disabled
	fi

	mount_filesystems

	chroot "$TARGET" bin/bash -i

	if [ -f $TARGET/etc/ld.so.preload.disabled ]; then
		mv $TARGET/etc/ld.so.preload.disabled $TARGET/etc/ld.so.preload
	fi
}

main "$@"
