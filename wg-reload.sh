#!/bin/bash
#
# Copyright (C) 2019 Henrik Hautakoski <henrik@eossweden.org>. All Rights Reserved.

if [ $# -lt 1 ]; then
	echo "usage: ${0##*/} <interface>"
	exit 1
fi

WG=$(which wg)
IP=$(which ip)
IFACE=$1
CONFIG_FILE=/etc/wireguard/${IFACE}.conf

# Call sudo if we are not root.
if [ $UID != 0 ]; then
	exec sudo -p "[sudo] root access is needed. password for %u: " -- "$BASH" -- "$0" "$@"
fi

if [ ! -f ${CONFIG_FILE} ]; then
	echo "File '${CONFIG_FILE}' does not exist"
	exit 1
fi

# Strip all wg-quick keys from the config file
# and pass the string as input to setconf
${WG} setconf ${IFACE} <(sed -E '/^[[:space:]]*(\#|Address|DNS|MTU|PreUp|PostUp|PreUp|PreDown|SaveConfig)/ d' ${CONFIG_FILE})

if [ $? -ne 0 ]; then
	echo "[ERROR] could not reload interface because of previous error."
	exit 1
fi

# To get rid of any old routing rules. We flush all of them :)
# This will also remove the IP address(es) which is kind of nice because then
# We don't need to check if it has been changed. can just add them :)
echo "[ROUTE] Flushing routing table"
${IP} addr flush ${IFACE}

# Add IP (This will also add the default route based on the CIDR-prefix)
ipaddr=$(sed -En 's/^[[:space:]]*Address[[:space:]]*\=[[:space:]]*([0-9\./]+)/\1/p' ${CONFIG_FILE})
echo "[IP] add ${ipaddr}"
$IP addr add ${ipaddr} dev ${IFACE}

# Reload routing rules
for addr in $(${WG} show "${IFACE}" allowed-ips | sed -En 's/^.*\t([0-9\.]+\/[0-9]+)$/\1/p'); do

	# Use ip command to lookup the address
	# If it tells us that the address wont be routed via ${IFACE} we need to add it.
	if [ -z "$(${IP} route get "${addr}" 2> /dev/null | grep "dev ${IFACE}")" ]; then
		echo "[ROUTE] add ${addr}"
		${IP} route add "$addr" dev "${IFACE}"
	fi
done

echo "[OK] ${IFACE} was reloaded successfully"
