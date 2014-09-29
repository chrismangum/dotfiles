#!/bin/bash
sudo iptables -F
sudo systemctl stop openvpn@client.service
