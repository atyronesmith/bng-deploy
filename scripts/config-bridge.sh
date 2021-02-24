export PUB_CONN=ens3f1
export PUB_IP=10.1.198.97/28
export PUB_DNS=10.11.5.19
export PUB_GW=10.1.198.110
export BRIDGE=br-ctlplane
nmcli con add ifname ${BRIDGE} type bridge con-name ${BRIDGE}
nmcli con add type ethernet slave-type bridge con-name "$PUB_CONN" ifname "$PUB_CONN" master ${BRIDGE}
nmcli con down "$PUB_CONN"; 
nmcli connection add ${BRIDGE} ipv4.addresses ${PUB_IP} ipv4.dns ${PUB_DNS} ipv4.gateway ${PUB_GW} ipv4.method manual
nmcli con down ${BRIDGE}
nmcli con up ${BRIDGE}
nmcli con show
