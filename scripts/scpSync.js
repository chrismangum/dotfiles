#!/usr/bin/env node

var chokidar = require('chokidar'),
    exec = require('child_process').exec,
    fs = require('fs'),
    moment = require('moment'),
    _ = require('underscore');

var appDescriptor = fs.readFileSync('appDescriptor.json').toString(),
    appId = JSON.parse(appDescriptor).appId,
    version = fs.readFileSync('version.txt').toString().replace('\n', ''),
    stackatoAppId = [
        appId,
        version.replace('.', '-'),
        moment().format('YYYYMM'),
        process.env.USER
    ].join('-'),
    watchers = [
        {
            path: 'WebContent/',
            remotePath: '',
            excludes: [],
        },
        {
            path: process.env.APOLLO_BASE_DIR + '/common/client/js/',
            remotePath: 'js/app/common/',
            excludes: [/vendor/],
        },
        {
            path: process.env.APOLLO_BASE_DIR + '/common/client/css/',
            remotePath: 'css/',
            excludes: [],
        }
    ];


function log(msg) {
    process.stdout.write(msg);
}

function syncFile(source, destination) {
    log('Updating file: ' + source + ' ... ');
    exec('stackato scp ' + stackatoAppId + ' ' + source + ' :' + destination, function (err, stdout, stderr) {
        if (err) {
            console.log('Error:');
            log(stdout + stderr);
        } else {
            console.log('Done.');
        }
    });
}

_.each(watchers, function (watcher) {
    var w = chokidar.watch(watcher.path, {persistent: true})
    w.on('change', function (filePath) {
        var dest, excluded;
        //ignore swap files
        watcher.excludes.unshift(/.swp$/);
        excluded = _.some(watcher.excludes, function (exclude) {
            return filePath.match(exclude);
        });
        if (!excluded) {
            dest = watcher.remotePath + filePath.replace(watcher.path, '');
            syncFile(filePath, dest);
        }
    });
});
