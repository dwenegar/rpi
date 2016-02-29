#!/bin/bash

set -e

if [ "$DISABLE_ROOT" != "false" ]; then
	if [ -f "$ROOT_SSH_PUBKEY" ]; then
		declare ssh_dir="/root/.ssh"
		mkdir -p "$TARGET/$ssh_dir"
		install -v -m 0600 "$ROOT_SSH_PUBKEY" "$TARGET/$ssh_dir/authorized_keys"
		in_target bin/bash <<-EOF
			chmod 0700 $ssh_dir
			chown -R root:root $ssh_dir
		EOF
	fi
elif [ -n "$ROOT_PASSWORD" ]; then
	in_target bin/bash <<-EOF
		echo "root:$ROOT_PASSWORD" | chpasswd
	EOF
fi
