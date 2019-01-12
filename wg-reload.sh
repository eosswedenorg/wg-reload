#!/bin/bash
#
# Copyright (C) 2019 Henrik Hautakoski <henrik@eossweden.org>. All Rights Reserved.

if [ $# -lt 1 ]; then
	echo "usage ${0##*/} <interface>"
	exit 1
fi

WG=$(which wg)
IFACE=$1
CONFIG_FILE=/etc/wireguard/${IFACE}.conf

if [ ! -f ${CONFIG_FILE} ]; then
	echo "File '${CONFIG_FILE}' does not exist"
	exit 1
fi

# Strip all wg-quick keys from the config file
# and pass the string as input to setconf
${WG} setconf ${IFACE} <(sed -E '/^(\s)*(Address|DNS|MTU|PreUp|PostUp|PreUp|PreDown|SaveConfig)/ d' ${CONFIG_FILE})

if [ $? -eq 0 ]; then
	echo "[OK] ${IFACE} was reloaded successfully"
else
	echo "[ERROR] '${CONFIG_FILE}' contains errors, interface was not reloaded"
	exit 1
fi
