export umount_dirs=""

umount_exit_function() {
	for dir in $umount_dirs; do
		info "Unmounting $dir"
		umount "$dir"
	done
}

umount_on_exit() {
	local -r dir="$1"
	if [ -z "$umount_dirs" ]; then
		umount_dirs="$dir"
	else
		umount_dirs="$dir $umount_dirs"
	fi
}

mount_filesystems() {
	info "Mounting file systems"

	trap umount_exit_function 0

	mount -t proc proc $TARGET/proc
	umount_on_exit $TARGET/proc

	mount -t sysfs none $TARGET/sys
	umount_on_exit $TARGET/sys

	mount -o bind /dev $TARGET/dev
	umount_on_exit $TARGET/dev

	mount -o bind /dev/pts $TARGET/dev/pts
	umount_on_exit $TARGET/dev/pts
}
