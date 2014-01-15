#!/usr/bin/env node

var exec = require('child_process').exec,
  async = require('async');

if (process.getuid() !== 0) {
  exec('sudo ./vpn_kill.js', function (err, stdout, stderr) {
    process.stdout.write(stdout + stderr);
  });
} else {
  async.parallel([
    function (callback) {
      console.log('Flushing iptables rules...');
      exec('iptables -F', callback);
    },
    function (callback) {
      console.log('Stopping OpenVPN...');
      exec('/etc/init.d/openvpn stop', callback);
    },
  ],
  function (err, results) {
    console.log(err ? err : 'Done.');
  });
}


