#!/usr/bin/env node

var chokidar = require('chokidar');
var watcher = chokidar.watch('WebContent', {persistent: true});
var exec = require('child_process').exec;

function log(msg) {
  process.stdout.write(msg);
}

watcher.on('change', function (path) {
    if (!path.match(/.swp$/)) {
        log('Updating file: ' + path + ' ... ');
        exec('stackato scp supportCases-1-1-201402-chris ' + path + ' :' + path.replace('WebContent/', ''), function (err, stdout, stderr) {
            if (err) throw err;
            console.log('Done.');
        });
    }
});

