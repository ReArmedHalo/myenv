#!/usr/bin/env bash

runTask() {
    curl -O https://raw.githubusercontent.com/angristan/openvpn-install/master/openvpn-install.sh
    chmod +x openvpn-install.sh

    export AUTO_INSTALL=y
    export APPROVE_INSTALL=y
    export APPROVE_IP=y
    export IPV6_SUPPORT=n
    export PROTOCOL_CHOICE=1
    export DNS=13
    export DNS1=10.8.0.1
    export DNS2=8.8.8.8
    export COMPRESSION_ENABLED=n
    export CUSTOMIZE_ENC=n
    export CLIENT=$MYSELF
    export PASS=1

    sudo -E ./openvpn-install.sh

    sudo sed -i 's/push "redirect-gateway def1 bypass-dhcp"/push "route 10.8.0.1\/32 vpn_gateway"/g' /etc/openvpn/server.conf
    sudo systemctl restart openvpn@server
    sudo chown $MYSELF: $MYSELF.ovpn
}