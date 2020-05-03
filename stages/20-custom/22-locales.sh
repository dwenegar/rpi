#!/bin/bash

set -e

if [ "$LOCALE" != "en_US.UTF-8" ]; then
	sed -i "/en_US.UTF-8/s/^#//" "$TARGET/etc/locale.gen"
fi
sed -i "/$LOCALE/s/^#//" "$TARGET/etc/locale.gen"

generate_debconf() {
	echo "locales locales/default_environment_locale select $LOCALE"
	if [ "$LOCALE" != "en_US.UTF-8" ]; then
		echo "locales locales/locales_to_be_generated multiselect $LOCALE UTF-8, en_US.UTF-8 UTF-8"
	else
		echo "locales locales/locales_to_be_generated multiselect $LOCALE UTF-8"
	fi
}

in_target debconf-set-selections -v <<-EOF
	$(generate_debconf)
EOF

in_target locale-gen
in_target update-locale LANG="$LOCALE"
