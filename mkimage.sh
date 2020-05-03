#!/bin/bash

set -ex

if [ "$(id -u)" != "0" ]; then
	echo "This script must be run as root"
	exit 1
fi

source scripts/logging.sh
source scripts/mount.sh

declare image_size=1024
declare boot_size=256M

#
# Configuration /end
#

declare target
declare bootp
declare rootp

create_file() {
	if [ ! -f $target ]; then
		dd if=/dev/zero of=$target bs=1M count=$image_size
	fi
}

create_partitions() {
	parted -s $target mklabel msdos
	parted -s $target mkpart primary fat32 0% $boot_size
	parted -s $target mkpart primary ext4 $boot_size 100%

	local -r loop_device=$(losetup -f --show "$target")

	kpartx -avs $loop_device

	bootp="$(echo $loop_device | sed -E "s/loop/mapper\/loop/")p1"
	rootp="$(echo $loop_device | sed -E "s/loop/mapper\/loop/")p2"

	mkfs.vfat -n PI_BOOT $bootp
	mkfs.ext4 -L PI_ROOT $rootp
}

mount_image() {
	local -r dir="$1"

	mount -t ext4 $rootp $dir
	mkdir -p $dir/boot
	mount -t vfat $bootp $dir/boot
}

main() {
	local -r rootfs="${1:-}"
	if [ -z "$rootfs" ]; then
		fail "You must provide a rootfs"
	fi

	target="$(basename $rootfs).img"

	create_file
	create_partitions

	local -r tmpdir=$(mktemp -d -p .)
	mount_image $tmpdir

	rsync --archive $rootfs/ $tmpdir/
	cat /dev/zero >$tmpdir/zeroes 2>/dev/null || true
	rm $tmpdir/zeroes
	umount $tmpdir/boot
	umount $tmpdir
	rmdir $tmpdir
	kpartx -d $target
}

main "$@"
