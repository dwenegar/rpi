#!/bin/bash

set -e

config_dnsmasq()
{
	copy_file /etc/dnsmasq.d/10tiny.dnsmasq.conf
	sed -e '/^DNS/d' -i "$TARGET/etc/systemd/network/eth0.network"
	echo "DNS=127.0.0.1" >> "$TARGET/etc/systemd/network/eth0.network"
}

config_nginx()
{
	sed -e 's|# server_names_hash_bucket_size|server_names_hash_bucket_size|' \
		-i "$TARGET/etc/nginx/nginx.conf"

	rm -fv "$TARGET/etc/nginx/sites-enabled/default"

	copy_file /etc/nginx/sites-available/00default

	copy_file /etc/systemd/system/nginx-folders.service
	in_target bin/bash -ex <<-EOF
		rm /etc/nginx/sites-enabled/default
		ln -s /etc/nginx/sites-available/00default /etc/nginx/sites-enabled/00default

		mkdir -p /etc/systemd/system/nginx.service.wants
		ln -s /etc/systemd/system/nginx-folders.service /etc/systemd/system/nginx.service.wants
		systemctl enable nginx-folders.service
	EOF
}

config_monit()
{
	copy_file /etc/monit/monitrc
	copy_file /etc/monit/conf.d/dnsmasq
	copy_file /etc/nginx/sites-available/20monit

	in_target bin/bash -ex <<-EOF
		chmod 0600 /etc/monit/monitrc
		ln -s /etc/monit/monitrc.d/nginx /etc/monit/conf.d/nginx
		ln -s /etc/monit/monitrc.d/openssh-server /etc/monit/conf.d/openssh-server
		ln -s /etc/nginx/sites-available/20monit /etc/nginx/sites-enabled/20monit
	EOF
}

config_logrotate()
{
	copy_file /etc/logrotate.d/dnsmasq.conf
	sed -e 's|#compress|compress|' -i "$TARGET/etc/logrotate.conf"
}

if [ -f "$TARGET/etc/ld.preload" ]; then
	mv "$TARGET/etc/ld.preload" "$TARGET/etc/ld.preload.disabledmc"
fi

in_target bin/bash -ex <<-EOF
	rm -fv /etc/resolv.conf
	echo "nameserver 8.8.8.8" > /etc/resolv.conf
EOF

config_nginx
config_monit
config_dnsmasq
config_logrotate

in_target bin/bash <<-EOF
	rm -f /etc/resolv.conf
	ln -s /run/systemd/resolve/resolv.conf /etc/resolv.conf
EOF

if [ -f "$TARGET/etc/ld.preload.disabled" ]; then
	mv "$TARGET/etc/ld.preload.disabled" "$TARGET/etc/ld.preload"
fi
