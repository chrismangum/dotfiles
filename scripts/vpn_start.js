#!/usr/bin/env node

var os = require('os'),
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

function run(command) {
  exec(command, function (error, stdout, stderr) {
    if (stdout.length) log(stdout);
    if (stderr.length) log(stderr);
  });
}

function log(string) {
  process.stdout.write(string);
}

function writeFile(filename, string_arr, callback) {
  fs.writeFile(filename, string_arr.join(os.EOL), function (err) {
    if (err) throw err;
    callback();
  });
}

function writeVpnConfig() {
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
  ], function () {
    run('/etc/init.d/openvpn restart');
  });
}

function writeIpRules(net_addr) {
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
  ], function () {
    run('iptables-restore < /etc/iptables.up.rules');
  });
}

function getNetAddress(callback) {
  var my_ip = ifaces[iface][0].address;
  exec('ip route | grep ' + my_ip, function (err, stdout) {
    callback(stdout.toString().split(' ')[0]);
  });
}

if (process.getuid() !== 0) {
  console.log('This script must be run as root.');
  process.exit(1);
} else {
  dns.resolve4('us-east.privateinternetaccess.com', function (err, addresses) {
    if (err) throw err;
    pia_ip = addresses[0];
    iface = getIface();
    writeVpnConfig();
    getNetAddress(writeIpRules);
  });
}

