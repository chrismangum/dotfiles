#! /usr/bin/python3
import os
import socket
import subprocess

def sh(cmd):
  return subprocess \
    .check_output(cmd, shell=True, universal_newlines=True) \
    .rstrip()

def joinLines(content):
  if type(content) == str:
    return content
  else:
    EOL = os.linesep
    return EOL.join(content) + EOL

def writeFile(filepath, content):
  f = open(filepath, 'w')
  f.write(joinLines(content))
  f.close()

sh('iptables -F')
sh('systemctl stop openvpn@client.service')

PIA = socket.gethostbyname('us-east.privateinternetaccess.com')
writeFile('/etc/openvpn/client.conf', [
  'up /etc/openvpn/update-resolv-conf',
  'down /etc/openvpn/update-resolv-conf',
  'script-security 2',
  'client',
  'dev tun',
  'proto udp',
  'remote ' + PIA + ' 1194',
  'resolv-retry infinite',
  'nobind',
  'persist-key',
  'persist-tun',
  'ca ca.crt',
  'tls-client',
  'remote-cert-tls server',
  'auth-user-pass login.txt',
  'comp-lzo',
  'verb 1',
  'reneg-sec 0'
])
sh('systemctl start openvpn@client.service')

CIDR = sh('ip route show scope link | grep -E "dev e(n|th)" | cut -d " " -f 1')
writeFile('/etc/iptables.up.rules', [
  '*filter',
  ':INPUT ACCEPT [0:0]',
  ':FORWARD ACCEPT [0:0]',
  ':OUTPUT ACCEPT [0:0]',
  '-A OUTPUT -o lo -j ACCEPT',
  '-A OUTPUT -o tun0 -j ACCEPT',
  '-A OUTPUT -d ' + CIDR + ' -j ACCEPT',
  '-A OUTPUT -d ' + PIA + ' -j ACCEPT',
  '-A OUTPUT -j DROP',
  'COMMIT'
])
sh('iptables-restore < /etc/iptables.up.rules')

print('Connected to:', PIA)
