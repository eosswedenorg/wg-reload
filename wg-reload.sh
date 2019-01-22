#!/bin/bash
#
# Copyright (C) 2019 Henrik Hautakoski <henrik@eossweden.org>. All Rights Reserved.

if [ $# -lt 1 ]; then
	echo "usage ${0##*/} <interface>"
	exit 1
fi

WG=$(which wg)
IP=$(which ip)
IFACE=$1
CONFIG_FILE=/etc/wireguard/${IFACE}.conf

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

# Check if we need to update IP
NEW_IP=$(sed -En 's/^[[:space:]]*Address[[:space:]]*\=[[:space:]]*([0-9\./]+)/\1/p' ${CONFIG_FILE})
CURRENT_IP=$(${IP} -o -4 addr show ${IFACE} | awk '{print $4}')

if [ "${NEW_IP}" != "${CURRENT_IP}" ]; then
	echo "Update to ${NEW_IP}"
	# NOTE: change,replace does NOT do what you want. have to use add+del
	$IP addr add ${NEW_IP} dev ${IFACE}
	$IP addr del ${CURRENT_IP} dev ${IFACE}
fi

echo "[OK] ${IFACE} was reloaded successfully"
