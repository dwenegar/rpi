#!/bin/bash

set -e

if [ -n "$USER_NAME" ]; then
	in_target	adduser --gecos "$USER_FULLNAME" --disabled-password --add_extra_groups "$USER_NAME"

	if [ -f "$USER_SSH_PUBKEY" ]; then
		declare ssh_dir="/home/$USER_NAME/.ssh"
		mkdir -p "$TARGET/$ssh_dir"
		install -v -m 0600 "$USER_SSH_PUBKEY" "$TARGET/$ssh_dir/authorized_keys"
		in_target bin/bash <<-EOF
			chmod 0700 $ssh_dir
			chown -R $USER_NAME:$USER_NAME $ssh_dir
		EOF
	fi

	if [ -n "$USER_PASSWORD" ]; then
		in_target bin/bash <<-EOF
			echo "$USER_NAME:$USER_PASSWORD" | chpasswd
		EOF
	fi
	if [ "$USER_IS_SUDOER" = "true" ]; then
		in_target usermod -aG sudo "$USER_NAME"
		if [ -z "$USER_PASSWORD" ]; then
			echo -n "$USER_NAME ALL = (ALL) NOPASSWD: ALL" > "$TARGET/etc/sudoers.d/$USER_NAME"
		fi
	fi
fi
