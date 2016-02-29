#!/bin/bash

set -e

sed "$TARGET/etc/hostname" -i -e "s|HOSTNAME|$HOSTNAME|"

{
	echo ""
	for hostname in $HOSTNAME $OTHER_HOSTNAMES; do
		if [ -n "$DOMAIN_NAME" ]; then
			echo "${IP_ADDRESS%%/*} $hostname.$DOMAIN_NAME $hostname"
		else
			echo "${IP_ADDRESS%%/*}  $hostname"
		fi
	done
} >> "$TARGET/etc/hosts"


if [ "$IP_ADDRESS" = "dhcp" ]; then
	copy_file \
		/etc/systemd/network/eth0.network.dhcp \
		/etc/systemd/network/eth0.network

	in_target apt-get install -y isc-dhcp-client
else
	copy_file \
		/etc/systemd/network/eth0.network.static \
		/etc/systemd/network/eth0.network
	{
		echo "Address=$IP_ADDRESS"
		echo "Gateway=$IP_GATEWAY"
		for nameserver in $IP_NAMESERVERS; do
			echo "DNS=$nameserver"
		done
		if [ -n "$DOMAIN_NAME" ]; then
			echo "Domains=$DOMAIN_NAME"
		fi
	} >> "$TARGET/etc/systemd/network/eth0.network"
fi

rm -fv "$TARGET/etc/resolv.conf"
in_target bin/bash <<-EOF
	systemctl disable systemd-resolved
	ln -s /run/systemd/resolve/resolv.conf /etc/resolv.conf
EOF
