#!/usr/bin/env node
var _ = require('lodash');
var chalk = require('chalk');
var fs = require('fs');
var moment = require('moment');
var os = require('os');
var path = require('path');
var program = require('commander');
var Promise = require('bluebird');
var request = require('request');
var util = require('util');

Promise.onPossiblyUnhandledRejection(_.noop);
var _console = _.mapValues({error: 'red', warn: 'yellow'}, function (color) {
    return function () {
        console.error(chalk[color].apply(chalk, arguments));
    };
});

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
    return getTwitchJson('users/' + username + '/follows/channels/', {limit: 150}).then(function (data) {
        return _.map(data.follows, 'channel.name');
    });
}

var getTwitchClientId = (function () {
    var clientId;
    return function () {
        if (clientId) {
            return Promise.resolve(clientId);
        }
        return readFile(path.join(os.homedir(), 'Desktop', 'twitch-client-id.txt')).then(function (buffer) {
            clientId = buffer.toString();
            return clientId;
        });
    };
}());

function getLiveStreams(query) {
    return getTwitchJson('streams/', query).then(function (data) {
        return _.map(data.streams, function (stream) {
            return {
                name: stream.channel.name,
                title: stream.channel.status,
                viewers: stream.viewers,
                game: stream.channel.game,
                uptime: moment(stream.created_at).fromNow(true)
            };
        });
    });
}

function getTwitchJson(path, query) {
    return getTwitchClientId().then(function (clientId) {
        return makeRequest({
            headers: {
                'Accept': 'application/vnd.twitchtv.v3+json',
                'Client-ID': clientId
            },
            json: true,
            qs: query,
            url: 'https://api.twitch.tv/kraken/' + path
        });
    });
}

function inspect(label, data) {
    console.log(chalk.bold.blue(label) + ':', util.inspect(data, {colors: true}));
}

function makeRequest(options) {
    return new Promise(function (resolve, reject) {
        request(options, function (err, response, data) {
            if (err || response.statusCode !== 200) {
                var error = err || 'call to ' + options.url + ' returned status: ' +
                    response.statusCode + ' ' + response.statusMessage;
                _console[err ? 'error' : 'warn'](error);
                reject(_.isError(error) ? error : new Error(error));
            } else {
                resolve(data);
            }
        });
    });
}

function prettyPrint(data) {
    console.log(JSON.stringify(data, null, 2));
}

function readFile(filename) {
    return new Promise(function(resolve, reject) {
        fs.readFile(filename, function (err, buffer) {
            if (err) {
                _console.error(err);
                reject(err);
            } else {
                resolve(buffer);
            }
        });
    });
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
        .then(prettyPrint);
} else {
    program.help();
}
