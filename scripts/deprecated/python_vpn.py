#! /usr/bin/python3

import socket
import subprocess

def sh(cmd):
  return subprocess \
    .check_output(cmd, shell=True, universal_newlines=True) \
    .rstrip()

CIDR = sh('ip route show scope link | grep -E "dev e(n|th)" | cut -d " " -f 1')
PIA = socket.gethostbyname('us-east.privateinternetaccess.com')

print({
  'CIDR': CIDR,
  'PIA': PIA
})

