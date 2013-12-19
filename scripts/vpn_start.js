#!/usr/bin/env node

var os = require('os'),
  fs = require('fs'),
  dns = require('dns'),
  exec = require('child_process').exec;

var iface, pia_ip, net_addr,
  ifaces = os.networkInterfaces();

function getIface() {
  for (var i in ifaces) {
    if (i.indexOf('eth') !== -1) {
      return i;
    }
  }
}

function run(command, callback) {
  exec(command, function (err, stdout, stderr) {
    if (callback) {
      if (err) throw err;
      callback(stdout);
    } else {
      process.stdout.write(stdout + stderr);
    }
  });
}

function writeFile(filename, string, callback) {
  fs.writeFile(filename, string, function (err) {
    if (err) throw err;
    callback();
  });
}

function writeVpnConfig(callback) {
  writeFile('/etc/openvpn/client.conf', [
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

function writeIpRules(callback) {
  writeFile('/etc/iptables.up.rules', [
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

function getNetAddress(callback) {
  run('ip route | grep ' + ifaces[iface][0].address, function (output) {
    net_addr = output.toString().split(' ')[0];
    callback();
  });
}

function getVpnIP(callback) {
  dns.resolve4('us-east.privateinternetaccess.com', function (err, addresses) {
    if (err) throw err;
    pia_ip = addresses[0];
    callback();
  });
}

if (process.getuid() !== 0) {
  run('sudo ./vpn_start.js');
} else {
  iface = getIface();
  getVpnIP(function () {
    writeVpnConfig(function () {
      run('/etc/init.d/openvpn restart');
    });
    getNetAddress(function () {
      writeIpRules(function () {
        run('iptables-restore < /etc/iptables.up.rules');
      });
    });
  });
}


