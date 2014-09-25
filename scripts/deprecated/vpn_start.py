#! /usr/bin/python3
import os
import socket
import subprocess
import sys

def sh(cmd):
  return subprocess \
    .check_output(cmd, shell=True, universal_newlines=True) \
    .rstrip()

def writeFile(filepath, content):
  f = open(filepath, 'w')
  f.write(content)
  f.close()

def getPing(ip):
  return sh('ping -c 1 %s | grep ttl | sed -r \'s/.*time=(\S+).*/\\1/\'' % ip)

if os.geteuid() != 0:
  print('Must be run as root.')
  sys.exit()

sh('iptables -F; systemctl stop openvpn@client.service')
# find the address with the shortest ping:
results = []
for ip in socket.gethostbyname_ex('us-east.privateinternetaccess.com')[2]:
  results.append((getPing(ip), ip))
PIA = sorted(results)[0][1]

writeFile('/etc/openvpn/client.conf',
'''up /etc/openvpn/update-resolv-conf
down /etc/openvpn/update-resolv-conf
script-security 2
client
dev tun
proto udp
remote %s 1194
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
reneg-sec 0''' % PIA)
sh('systemctl start openvpn@client.service')

sh('''sudo iptables -A OUTPUT -o lo -j ACCEPT
sudo iptables -A OUTPUT -o tun0 -j ACCEPT
sudo iptables -A OUTPUT -d %(CIDR)s -j ACCEPT
sudo iptables -A OUTPUT -d %(PIA)s -j ACCEPT
sudo iptables -A OUTPUT -j DROP''' % {
  'CIDR': sh('ip route show scope link | grep -E "dev e(n|th)" | cut -d " " -f 1'),
  'PIA': PIA
})

print('Connected to:', PIA)
