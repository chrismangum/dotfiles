#! /usr/bin/python3
import socket
import subprocess

def sh(cmd):
  return subprocess \
    .check_output(cmd, shell=True, universal_newlines=True) \
    .rstrip()

def writeFile(filepath, content):
  f = open(filepath, 'w')
  f.write(content)
  f.close()

sh('iptables -F; systemctl stop openvpn@client.service')

PIA = socket.gethostbyname('us-east.privateinternetaccess.com')
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
