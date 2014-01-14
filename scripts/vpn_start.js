#!/usr/bin/env node

var os = require('os'),
  async = require('async'),
  fs = require('fs'),
  dns = require('dns'),
  exec = require('child_process').exec;

var iface, pia_ip,
  ifaces = os.networkInterfaces();

function getIface() {
  for (var i in ifaces) {
    if (i.indexOf('eth') !== -1) {
      return i;
    }
  }
}

function writeVpnConfig(addresses, callback) {
  pia_ip = addresses[0];
  fs.writeFile('/etc/openvpn/client.conf', [
    'up /etc/openvpn/update-resolv-conf',
    'down /etc/openvpn/update-resolv-conf',
    'script-security 2',
    'client',
    'dev tun',
    'proto udp',
    'remote ' + pia_ip + ' 1194',
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
    'reneg-sec 0' + os.EOL
  ].join(os.EOL), callback);
}

function writeIpRules(net_addr, stderr, callback) {
  net_addr = net_addr.toString().split(' ')[0];
  fs.writeFile('/etc/iptables.up.rules', [
    '*filter',
    ':INPUT ACCEPT [0:0]',
    ':FORWARD ACCEPT [0:0]',
    ':OUTPUT ACCEPT [0:0]',
    '-A OUTPUT -o lo -j ACCEPT',
    '-A OUTPUT -o tun0 -j ACCEPT',
    '-A OUTPUT -o ' + iface + ' -d ' + net_addr + ' -j ACCEPT',
    '-A OUTPUT -o ' + iface + ' -d ' + pia_ip + ' -j ACCEPT',
    '-A OUTPUT -j DROP',
    'COMMIT' + os.EOL
  ].join(os.EOL), callback);
}

if (process.getuid() !== 0) {
  console.log('run as sudo');
} else {
  iface = getIface();
  async.waterfall([
    function (callback) {
      dns.resolve4('us-east.privateinternetaccess.com', callback);
    },
    writeVpnConfig,
    function (callback) {
      exec('/etc/init.d/openvpn restart', callback);
    },
    //get network address:
    function (stdout, stderr, callback) {
      exec('ip route | grep ' + ifaces[iface][0].address, callback);
    },
    writeIpRules,
    function (callback) {
      exec('iptables-restore < /etc/iptables.up.rules', callback);
    }
  ], function (err, result) {
      if (err) throw err;
      console.log('Done.');
    }
  );
}
