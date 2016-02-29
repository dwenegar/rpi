#!/bin/bash

set -e

info "Initializing keyring"

readonly raspbian_archive="https://archive.raspbian.org"
readonly raspbian_archive_key="raspbian.public.key"
readonly raspbian_archive_key_sha256="A0DA38D0D76E8B5D638872819165938D90FDDD2E"

import_key()
{
	local -r mirror="$1"
	local -r key="$2"
	local -r sha256="$3"

	info "Importing $key"
	local -r output="$BUILD_DIR/$key"

	curl -# -o $output $mirror/$key
	if [ "$(gpg $output | grep -c ^pub)" -gt 1 ] ; then
		fail "More than one key in $output"
	fi
	if [ "$(gpg --with-fingerprint --with-colons $output | grep ^fpr: | awk -F: '{print $10}')" != "$sha256" ] ; then
		fail "Invalid hash for $output"
	fi

	gpg --import "$output"
}

rm -rf "$GNUPGHOME"
mkdir -m 0700 "$GNUPGHOME"

gpg --list-secret-keys
import_key $raspbian_archive $raspbian_archive_key $raspbian_archive_key_sha256
