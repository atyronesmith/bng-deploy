#!/usr/bin/bash

# shellcheck source=common.sh
source common.sh

nmcli con add ifname "${BRIDGE}" type bridge con-name "${BRIDGE}"
nmcli con add type ethernet slave-type bridge con-name "$PUB_CONN" ifname "$PUB_CONN" master "${BRIDGE}"
nmcli con down "$PUB_CONN"; 
nmcli connection add "${BRIDGE}" ipv4.addresses "${PUB_IP}" ipv4.gateway "${PUB_GW}" ipv4.method manual
nmcli con down "${BRIDGE}"
nmcli con up "${BRIDGE}"
nmcli con show
