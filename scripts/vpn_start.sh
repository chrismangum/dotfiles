#!/bin/bash

sudo iptables -F
sudo /etc/init.d/openvpn stop

pia_ip=$(host us-east.privateinternetaccess.com | head -n 1 | cut -d " " -f 4)

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
sudo iptables -A OUTPUT -o eth0 -d 192.168.99.0/24 -j ACCEPT
sudo iptables -A OUTPUT -o eth0 -d $pia_ip -j ACCEPT
sudo iptables -A OUTPUT -j DROP
