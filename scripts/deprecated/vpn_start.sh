#!/bin/bash

sudo iptables -F
sudo /etc/init.d/openvpn stop

pia_ip=$(host us-east.privateinternetaccess.com | head -n 1 | cut -d " " -f 4)
iface=$(ip link | grep "state UP" | sed -r "s/[0-9]: (.*): .*/\1/")
my_ip=$(ifconfig $iface | grep -Eo "([0-9]{1,3}\.){3}[0-9]{1,3}" | head -n 1)
net_addr=$(ip route | grep $my_ip | cut -d " " -f 1)

echo "up /etc/openvpn/update-resolv-conf
down /etc/openvpn/update-resolv-conf
script-security 2
client
dev tun
proto udp
remote $pia_ip 1194
resolv-retry infinite
nobind
persist-key
persist-tun
ca ca.crt
tls-client
remote-cert-tls server
auth-user-pass login.txt
comp-lzo
verb 1
reneg-sec 0" | sudo tee /etc/openvpn/client.conf

sudo /etc/init.d/openvpn start

sudo iptables -A OUTPUT -o lo -j ACCEPT
sudo iptables -A OUTPUT -o tun0 -j ACCEPT
#allow traffic on local network
sudo iptables -A OUTPUT -o $iface -d $net_addr -j ACCEPT
sudo iptables -A OUTPUT -o $iface -d $pia_ip -j ACCEPT
sudo iptables -A OUTPUT -j DROP
