#!/bin/bash

set -e

in_target apt-get -y clean

find "$TARGET/etc/apt" -type f -name "*.save" -delete

rm -fv "$TARGET/boot/.firmware_revision"
rm -fv "$TARGET/etc/*-"
rm -fv "$TARGET/etc/NetworkManager/system-connections/*"
rm -fv "$TARGET/etc/resolvconf/resolv.conf.d/original"
rm -fv "$TARGET/etc/ssh/ssh_host_*.pub"
rm -fv "$TARGET/etc/ssh/ssh_host_*key"
rm -fv "$TARGET/etc/udev/rules.d/70-persistent-cd.rules"
rm -fv "$TARGET/etc/udev/rules.d/70-persistent-net.rules"
rm -fv "$TARGET/root/.bash_history"
rm -fv "$TARGET/root/.ssh/known_hosts"
rm -fv "$TARGET/run/*/*pid"
rm -fv "$TARGET/run/*pid"
rm -fv "$TARGET/run/cups/cups.sock"
rm -fv "$TARGET/run/uuidd/request"
rm -fv "$TARGET/var/crash/*"
rm -fv "$TARGET/var/lib/urandom/random-seed"
rm -rf "$TARGET/boot.bak"
rm -rf "$TARGET/lib/modules.bak"
rm -rf "$TARGET/tmp/*"
rm -rfv "$TARGET/usr/sbin/policy-rc.d"

[ -L $TARGET/var/lib/dbus/machine-id ] || rm \-fv $TARGET/var/lib/dbus/machine-id
echo '' >/etc/machine-id

if [ -f "$TARGET/etc/ld.preload.disabled" ]; then
	mv "$TARGET/etc/ld.preload.disabled" "$TARGET/etc/ld.preload"
fi
