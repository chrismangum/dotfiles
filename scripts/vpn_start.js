#!/usr/bin/env node

var os = require('os'),
  async = require('async'),
  _ = require('underscore'),
  fs = require('fs'),
  dns = require('dns'),
  exec = require('child_process').exec;

var pia_ip,
  ifaces = os.networkInterfaces();

function getDefaultIface() {
  return _.find(_.keys(ifaces), arrStrIndexOf('eth'));
}

function arrStrIndexOf(string) {
  return function (item) {
    return item.indexOf(string) !== -1;
  }
}

function writeVpnConfig(addresses, callback) {
  log('Done.\nWriting VPN config file: ');
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

function writeIpRules(net_addr, callback) {
  log('Done.\nWriting iptables rule file: ');
  fs.writeFile('/etc/iptables.up.rules', [
    '*filter',
    ':INPUT ACCEPT [0:0]',
    ':FORWARD ACCEPT [0:0]',
    ':OUTPUT ACCEPT [0:0]',
    '-A OUTPUT -o lo -j ACCEPT',
    '-A OUTPUT -o tun0 -j ACCEPT',
    '-A OUTPUT -d ' + net_addr + ' -j ACCEPT',
    '-A OUTPUT -d ' + pia_ip + ' -j ACCEPT',
    '-A OUTPUT -j DROP',
    'COMMIT' + os.EOL
  ].join(os.EOL), callback);
}

function log(msg) {
  process.stdout.write(msg);
}

if (process.getuid() !== 0) {
  exec('sudo ./vpn_start.js', function (err, stdout, stderr) {
    log(stdout + stderr);
  });
} else {
  async.waterfall([
    function (callback) {
      log('Getting VPN IP: ');
      dns.resolve4('us-east.privateinternetaccess.com', callback);
    },
    writeVpnConfig,
    function (callback) {
      log('Done.\nStarting OpenVPN: ');
      exec('/etc/init.d/openvpn restart', callback);
    },
    //get routes:
    function (stdout, stderr, callback) {
      exec('ip route', callback);
    },
    //isolate net addr:
    function (stdout, stderr, callback) {
      var routes, my_ip, net_addr;
      routes = stdout.toString().split('\n'),
      my_ip = ifaces[getDefaultIface()][0].address,
      net_addr = _.find(routes, arrStrIndexOf(my_ip)).split(' ')[0];
      callback(null, net_addr);
    },
    writeIpRules,
    function (callback) {
      log('Done.\nApplying iptables rules: ');
      exec('iptables-restore < /etc/iptables.up.rules', callback);
    }
  ], function (err, result) {
      console.log(err ? 'Failed.\n' + err : 'Done.');
    }
  );
}
