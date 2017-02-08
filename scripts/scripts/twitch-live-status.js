#!/usr/bin/env node
'use strict';
var _ = require('lodash');
var chalk = require('chalk');
var os = require('os');
var path = require('path');
var program = require('commander');
var Promise = require('bluebird');
var request = require('request');
var util = require('util');

var pRequest = Promise.promisify(request);
var readFile = Promise.promisify(require('fs').readFile);

function buildQuery(program) {
    var query = {stream_type: 'live'};
    _.assign(query, _.pick(program, 'game', 'limit'));
    if (program.username) {
        return getFollowing(program.username).then(function (channels) {
            query.channel = _.join(channels);
            return query;
        });
    }
    return Promise.resolve(query);
}

function getFollowing(username) {
    return getTwitchUserId(username).then(function (userId) {
        return getTwitchJson('users/' + userId + '/follows/channels/', {limit: 200}).then(function (data) {
            return _.map(data.follows, 'channel._id');
        });
    });
}

function getLiveStreams(query) {
    return getTwitchJson('streams/', query).then(function (data) {
        return _.mapValues(_.groupBy(data.streams, 'channel.game'), function (streams) {
            return _.mapValues(_.keyBy(streams, 'channel.name'), function (stream) {
                return {
                    title: stream.channel.status,
                    viewers: stream.viewers,
                    quality: stream.video_height + 'p' + (Math.round(stream.average_fps / 10) * 10)
                };
            });
        });
    });
}

var getTwitchClientId = (function () {
    var clientId;
    return function () {
        if (clientId) {
            return Promise.resolve(clientId);
        }
        return readFile(path.join(os.homedir(), 'Desktop', 'twitch-client-id.txt')).then(function (buffer) {
            clientId = _.first(_.toString(buffer).match(/\w+/));
            return clientId || Promise.reject(new Error('Unable to parse twitch client id'));
        });
    };
}());

function getTwitchJson(path, query) {
    return getTwitchClientId().then(function (clientId) {
        return makeRequest({
            headers: {
                'Accept': 'application/vnd.twitchtv.v5+json',
                'Client-ID': clientId
            },
            json: true,
            qs: query,
            url: 'https://api.twitch.tv/kraken/' + path
        });
    });
}

function getTwitchUserId(username) {
    return getTwitchJson('users/', {login: username}).then(function (data) {
        return _.get(_.first(data.users), '_id');
    });
}

function inspect(label, data) {
    console.log(chalk.bold.blue(label) + ':', util.inspect(data, {colors: true}));
}

function logError(error) {
    if (_.isError(error)) {
        console.error(chalk.red('Error') + ':', error.message);
    } else {
        console.error(chalk.yellow('Warning') + ':', error);
    }
}

function makeRequest(options) {
    return pRequest(options).then(function (res) {
        if (res.statusCode !== 200) {
            return Promise.reject('call to ' + options.url + ' returned status: ' + res.statusCode +
                                  ' ' + res.statusMessage);
        } else {
            return res.body;
        }
    });
}

function prettyPrint(data) {
    console.log(JSON.stringify(data, null, 4));
}

program
    .option('-g, --game <game>', 'Streams categorized under GAME')
    .option('-u, --username <username>', 'Username to query live followed streams')
    .option('-l, --limit <limit>', 'Maximum number of objects in array. Default is 25. Maximum is 100.')
    .option('-d, --debug', 'Turn on http request debugging')
    .parse(process.argv);

if (program.game || program.username) {
    if (program.debug) {
        require('request-debug')(request, inspect);
    }
    buildQuery(program)
        .then(getLiveStreams)
        .then(prettyPrint)
        .catch(logError);
} else {
    program.help();
}
