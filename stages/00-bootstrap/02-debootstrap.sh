#!/bin/bash

set -e

info "Bootstrapping $RELEASE in $TARGET"

http_proxy=http://localhost:3142 \
	qemu-debootstrap \
	--arch=armhf \
	--variant=minbase \
	--keyring="$GNUPGHOME/pubring.gpg" \
	stretch $TARGET $MIRROR
