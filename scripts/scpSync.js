#!/usr/bin/env node

var chokidar = require('chokidar');
var exec = require('child_process').exec;
var fs = require('fs');
var moment = require('moment');
var _ = require('underscore');

function log(msg) {
    process.stdout.write(msg);
}

function getAppId() {
    if (!appId) {
        appId = fs.readFileSync('appDescriptor.json').toString();
        appId = JSON.parse(appId).appId;
        var version = fs.readFileSync('version.txt').toString();
        appId += '-' + version.replace('.', '-').replace('\n', '');
        appId += '-' + moment().format('YYYYMM');
        appId += '-' + process.env.USER;
    }
    return appId;
}

function syncFile(source, destination) {
    log('Updating file: ' + source + ' ... ');
    exec('stackato scp ' + getAppId() + ' ' + source + ' :' + destination, function (err, stdout, stderr) {
        if (err) {
            console.log('Error:');
            log(stdout + stderr);
            watcher.close();
        } else {
            console.log('Done.');
        }
    });
}

var watchers = [
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
]

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
