#!/usr/bin/env node

var os = require('os'),
  Q = require('q'),
  _ = require('underscore'),
  fs = require('fs'),
  dns = require('dns'),
  child_process = require('child_process');

var pia_ip,
  dnsLookup = Q.denodeify(dns.resolve4),
  writeFile = Q.denodeify(fs.writeFile),
  exec = Q.denodeify(child_process.exec);

function log(msg) {
  if (_.isArray(msg)) {
    msg = _.first(msg);
  }
  if (msg) {
    process.stdout.write(msg);
  }
}

function getIP() {
  return _.find(os.networkInterfaces(), function (iface, name) {
    return /^e(n|th)/.test(name);
  })[0].address;
}

function getNetAddr(ipRoute) {
  var ip = getIP();
  return _.find(ipRoute.split('\n'), function (line) {
    return line.indexOf(ip) !== -1;
  }).split(' ')[0];
}

function writeIpRules(stdout) {
  log('Done.\nWriting iptables rule file: ');
  return writeFile('/etc/iptables.up.rules', [
    '*filter',
    ':INPUT ACCEPT [0:0]',
    ':FORWARD ACCEPT [0:0]',
    ':OUTPUT ACCEPT [0:0]',
    '-A OUTPUT -o lo -j ACCEPT',
    '-A OUTPUT -o tun0 -j ACCEPT',
    '-A OUTPUT -d ' + getNetAddr(stdout[0]) + ' -j ACCEPT',
    '-A OUTPUT -d ' + pia_ip + ' -j ACCEPT',
    '-A OUTPUT -j DROP',
    'COMMIT' + os.EOL
  ].join(os.EOL));
}

function writeVpnConfig(addresses) {
  log('Done.\nWriting VPN config file: ');
  pia_ip = addresses[0];
  return writeFile('/etc/openvpn/client.conf', [
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
  ].join(os.EOL));
}

if (process.getuid() !== 0) {
  exec('sudo ./vpn_start.js').then(log);
} else {
  log('Getting VPN IP: ');
  dnsLookup('us-east.privateinternetaccess.com')
    .then(writeVpnConfig)
    .then(function () {
      log('Done.\nStarting OpenVPN: ');
      return exec('systemctl restart openvpn@client.service');
    })
    .then(function() {
      return exec('ip route');
    })
    .then(writeIpRules)
    .then(function () {
      log('Done.\nApplying iptables rules: ');
      return exec('iptables-restore < /etc/iptables.up.rules');
    })
    .then(function() {
      console.log('Done.');
    })
    .catch(function (err) {
       console.log('Failed.\n' + err);
    });
}
