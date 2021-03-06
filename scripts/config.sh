load_config() {
	local -r config="$1"
	if [ -n "$config" ] && [ -f "$config" ]; then
		info "Loading $config"
		source "$config"
	fi
}

show_config() {
	info "Configuation:"
	info "  MIRROR = $MIRROR"
	info "  NO_RECOMMENDS = $NO_RECOMMENDS"
	info "  DISABLE_ROOT = $DISABLE_ROOT"
	if [ "$DISABLE_ROOT" = "false" ]; then
		info "  ROOT_PASSWORD = $ROOT_PASSWORD"
		if [ -n "$ROOT_SSH_PUBKEY" ]; then
			info "  ROOT_SSH_PUBKEY = $ROOT_SSH_PUBKEY"
		fi
	fi
	info "  USER_FULLNAME = $USER_FULLNAME"
	info "  USER_NAME = $USER_NAME"
	info "  USER_PASSWORD = $USER_PASSWORD"
	if [ -n "$USER_SSH_PUBKEY" ]; then
		info "  USER_SSH_PUBKEY = $USER_SSH_PUBKEY"
	fi
	info "  USER_IS_SUDOER = $USER_IS_SUDOER"
	info "  INTERFACE = $INTERFACE"
	info "  HOSTNAME = $HOSTNAME"
	info "  DOMAIN_NAME = $DOMAIN_NAME"
	info "  IP_ADDRESS = $IP_ADDRESS"
	if [ "$IP_ADDRESS" != "dhcp" ]; then
		info "  IP_GATEWAY = $IP_GATEWAY"
		info "  IP_NAMESERVERS = ${IP_NAMESERVERS[*]}"
	fi
	info "  LOCALE = $LOCALE"
	info "  TIMEZONE = $TIMEZONE"
	info "  ENABLE_WATCHDOG = $ENABLE_WATCHDOG"
	info "  REDUCE = $REDUCE"
}

verify_config() {
	if [ "$IP_ADDRESS" != "dhcp" ]; then
		[ -n "$IP_GATEWAY" ] || fail "IP_GATEWAY is missing"
		[ -n "$IP_NAMESERVERS" ] || fail "IP_NAMESERVERS is missing"
	fi
	if [ -n "$ROOT_SSH_PUBKEY" ]; then
		[ -f "$ROOT_SSH_PUBKEY" ] || fail "root's ssh public key file ($ROOT_SSH_PUBKEY) is missing"
	fi
	if [ -n "$USER_NAME" ] && [ -n "$USER_SSH_PUBKEY" ]; then
		[ -f "$USER_SSH_PUBKEY" ] || fail "$USER_NAME's ssh public key file ($USER_SSH_PUBKEY) is missing"
	fi
}

sanitize_config() {
	DISABLE_ROOT=$(sanitize_bool $DISABLE_ROOT)
	USER_IS_SUDOER=$(sanitize_bool $USER_IS_SUDOER)
	ENABLE_WATCHDOG=$(sanitize_bool $ENABLE_WATCHDOG)
	NO_RECOMMENDS=$(sanitize_bool $NO_RECOMMENDS)
	REDUCE=$(sanitize_bool $REDUCE)
	if [ -f "$USER_SSH_PUBKEY" ]; then
		USER_SSH_PUBKEY=$(readlink -f "$USER_SSH_PUBKEY")
	fi
	if [ -f "$ROOT_SSH_PUBKEY" ]; then
		ROOT_SSH_PUBKEY=$(readlink -f "$ROOT_SSH_PUBKEY")
	fi
	if [ "$DISABLE_ROOT" = "false" ] && [ -z "$ROOT_PASSWORD" ]; then
		ROOT_PASSWORD=$(mkpasswd root)
	fi
	if [ -n "$USER_NAME" ] && [ -z "$USER_PASSWORD" ]; then
		USER_PASSWORD=$(mkpasswd "$USER_NAME")
	fi
}

sanitize_bool() {
	local -r value="${1:-false}"
	case $value in
	false | no | 0) echo "false" ;;
	*) echo "true" ;;
	esac
}
