#!/usr/bin/env node
'use strict';
var _ = require('lodash');
var chalk = require('chalk');
var moment = require('moment');
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

function formatDuration(value, unit) {
    var duration = moment.duration(value, unit);
    return _.reduce(['hours', 'minutes', 'seconds'], function (memo, unit) {
        var val = duration[unit]();
        if (memo) {
            memo += ':' + (val < 10 ? '0' + val : _.toString(val));
        } else if (val) {
            memo += val;
        }
        return memo;
    }, '');
}

function getFollowing(username) {
    return getUserId(username).then(function (userId) {
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

var getClientId = (function () {
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
    return getClientId().then(function (clientId) {
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

function getUserId(username) {
    return getTwitchJson('users/', {login: username}).then(function (data) {
        return _.get(_.first(data.users), '_id');
    });
}

function getVods(query) {
    _.defaults(query, { broadcast_type: 'archive' });
    return getTwitchJson('videos/top', query).then(function (data) {
        return _.mapValues(_.groupBy(data.vods, 'channel.name'), function (vods) {
            return _.map(vods, function (vod) {
                return {
                    title: vod.title,
                    created: moment(vod.created_at).fromNow(),
                    duration: formatDuration(vod.length, 'seconds'),
                    views: vod.views,
                    quality: _.last(_.split(vod.resolutions.chunked, 'x')) + 'p' +
                        (Math.round(vod.fps.chunked / 10) * 10),
                    url: vod.url
                };
            });
        });
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
    .option('-v, --vods', 'Fetch game vods. Requires --game argument.')
    .parse(process.argv);

if (program.debug) {
    require('request-debug')(request, inspect);
}
if (program.game && program.vods) {
    delete program.username
    buildQuery(program)
        .then(getVods)
        .then(prettyPrint)
        .catch(logError);
} else if (program.game || program.username) {
    buildQuery(program)
        .then(getLiveStreams)
        .then(prettyPrint)
        .catch(logError);
} else {
    program.help();
}
