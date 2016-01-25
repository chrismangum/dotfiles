#!/bin/bash
set -e

main_interface=$(ip route show scope link | grep -E 'dev e(n|th)' | awk '{print $3}')
local_network=$(ip route show scope link | grep -E "$main_interface" | awk '{print $1}')
pia=$(ip route show scope link | grep 'dev tun0' | awk '{print $NF}')

{
    sudo ufw --force reset

    # Default policies
    sudo ufw default deny incoming
    sudo ufw default deny outgoing

    # Openvpn interface
    sudo ufw allow in on tun0
    sudo ufw allow out on tun0

    # Local Network
    sudo ufw allow in on $main_interface from $local_network
    sudo ufw allow out on $main_interface to $local_network

    # Openvpn
    sudo ufw allow out on $main_interface to $pia
    sudo ufw allow in on $main_interface from $pia

    # DNS
    sudo ufw allow in from any to any port 53
    sudo ufw allow out from any to any port 53
} > /dev/null

sudo ufw enable
sudo ufw status
