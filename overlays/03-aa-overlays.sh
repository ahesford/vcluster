# vim: set ts=4 sw=4 et:

if [ -r /sys/class/net/eth0/address ]; then
	read -r _macaddr < /sys/class/net/eth0/address
	if [ -n "${_macaddr}" ]; then
		_overlay="/etc/overlays/${_macaddr}"

		for _olf in "${_overlay}".*; do
			[ -r "${_olf}" ] || continue
			msg "Attempting to unpack overlay ${_olf}..."
			if ! tar -xf "${_olf}" -C /etc; then
				msg_warn "Failed to unpack overlay ${_olf}"
			fi
		done
		unset _olf

		if [ -d "${_overlay}" ]; then
			msg "Attempting to unpack overlay ${_overlay}..."
			if ! (tar -cf - -C "${_overlay}" . | tar -xf - -C /etc); then
				msg_warn "Failed to unpack overlay ${_overlay}"
			fi
		fi
	       
		unset _overlay
	fi
	unset _macaddr
fi
