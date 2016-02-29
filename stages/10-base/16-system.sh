#!/bin/bash

set -e

copy_file /etc/host.conf
copy_file /etc/network/interfaces

copy_file /etc/hostname
copy_file /etc/hosts
copy_file /etc/modprobe.d/ipv6.conf
copy_file /etc/network/interfaces

copy_file /etc/adduser.conf
copy_file /etc/fstab

copy_file /etc/modprobe.d/rpi-blacklist.conf

copy_file /etc/modules-load.d/rpi.conf

copy_file /etc/sysctl.d/98-rpi.conf

copy_file /etc/systemd/system/getty@tty1.service.d/noclear.conf
copy_file /etc/systemd/system/rc-local.service.d/ttyoutput.conf
copy_file /etc/systemd/system/sshdgenkeys.service
in_target bin/bash <<-EOF
	mkdir -p /etc/systemd/system/ssh.service.wants
	ln -s /etc/systemd/system/sshdgenkeys.service /etc/systemd/system/ssh.service.wants
EOF

copy_file /usr/share/initramfs-tools/hooks/resize
copy_file /usr/share/initramfs-tools/scripts/local-premount/resize

in_target bin/bash <<-EOF
	groupadd -f --system gpio
	groupadd -f --system i2c
	groupadd -f --system input
	groupadd -f --system spi

	echo "root:root" | chpasswd

	update-initramfs -v -cu -k all

	fake-hwclock save

	rm -rf /etc/default/console-setup
	dpkg-reconfigure -f noninteractive console-setup
	setupcon --force --save-only -v

	rm -rf /etc/default/keyboard
	dpkg-reconfigure -f noninteractive keyboard-configuration

	systemctl enable systemd-networkd
EOF

sed -e 's|AcceptEnv|#AcceptEnv|' -i "$TARGET/etc/ssh/sshd_config"
