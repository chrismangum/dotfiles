#!/usr/bin/env node

var os = require('os'),
  Q = require('q'),
  _ = require('underscore'),
  fs = require('fs'),
  dns = require('dns'),
  child_process = require('child_process');

var pia_ip,
  dnsLookup = Q.denodeify(dns.lookup),
  fsWriteFile = Q.denodeify(fs.writeFile),
  exec = Q.denodeify(child_process.exec);

function log(msg) {
  _.each(_.isArray(msg) ? msg : [msg], function (msg) {
    if (msg) {
      process.stdout.write(msg);
    }
  });
}

function writeFile(path, arr) {
  return fsWriteFile(path, arr.join(os.EOL) + os.EOL);
}

function writeIpRules(stdout) {
  return writeFile('/etc/iptables.up.rules', [
    '*filter',
    ':INPUT ACCEPT [0:0]',
    ':FORWARD ACCEPT [0:0]',
    ':OUTPUT ACCEPT [0:0]',
    '-A OUTPUT -o lo -j ACCEPT',
    '-A OUTPUT -o tun0 -j ACCEPT',
    '-A OUTPUT -d ' + stdout[0].trim() + ' -j ACCEPT',
    '-A OUTPUT -d ' + pia_ip + ' -j ACCEPT',
    '-A OUTPUT -j DROP',
    'COMMIT'
  ]);
}

function writeVpnConfig(addresses) {
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
    'reneg-sec 0'
  ]);
}

function step(sequence) {
  _.reduce(sequence, function (promise, item) {
    return promise.then(item);
  }, Q()).then(function() {
    console.log('Connected to: ' + pia_ip);
  }).catch(log);
}

if (process.getuid() !== 0) {
  exec('sudo ./vpn_start.js').then(log);
} else {
  step([
    _.partial(dnsLookup, 'us-east.privateinternetaccess.com'),
    writeVpnConfig,
    _.partial(exec, 'systemctl restart openvpn@client.service'),
    _.partial(exec, 'ip route show scope link | grep -E "dev e(n|th)" | cut -d " " -f 1'),
    writeIpRules,
    _.partial(exec, 'iptables-restore < /etc/iptables.up.rules')
  ]);
}
