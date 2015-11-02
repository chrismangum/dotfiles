#!/bin/bash
set -e

sudo iptables -F
sudo systemctl stop openvpn@client.service

PIA=$(host us-east.privateinternetaccess.com | head -n 1 | cut -d " " -f 4)
CIDR=$(ip route show scope link | grep -P "dev e(n|th)" | cut -d " " -f 1)

echo "up /etc/openvpn/update-resolv-conf
down /etc/openvpn/update-resolv-conf
script-security 2
client
dev tun
proto tcp
remote $PIA 443
resolv-retry infinite
nobind
persist-key
persist-tun
ca /etc/openvpn/ca.crt
tls-client
remote-cert-tls server
auth-user-pass /etc/openvpn/login.txt
comp-lzo
verb 1
reneg-sec 0" | sudo tee /etc/openvpn/client.conf &> /dev/null

sudo systemctl start openvpn@client.service

sudo iptables -A OUTPUT -o lo -j ACCEPT
sudo iptables -A OUTPUT -o tun0 -j ACCEPT
sudo iptables -A OUTPUT -d $CIDR -j ACCEPT
sudo iptables -A OUTPUT -d $PIA -j ACCEPT
sudo iptables -A OUTPUT -j DROP

echo "Connected to: $PIA"
