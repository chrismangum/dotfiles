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

var getFileToken = (function () {
    var cache = {};
    return function (filename) {
        if (cache[filename]) {
            return Promise.resolve(cache[filename]);
        }
        return readFile(path.join(os.homedir(), 'Desktop', filename)).then(function (buffer) {
            cache[filename] = _.first(_.toString(buffer).match(/\w+/));
            return cache[filename] || Promise.reject(new Error('Unable to parse token in ' + filename));
        });
    };
}());
var getClientId = _.partial(getFileToken, 'twitch-client-id.txt');
var getOauthToken = _.partial(getFileToken, 'twitch-oauth-token.txt');

function formatDuration(value, unit) {
    var duration = moment.duration(value, unit);
    return _.reduce(['hours', 'minutes', 'seconds'], function (memo, unit) {
        var val = duration[unit]();
        if (memo) {
            memo += ':' + (val < 10 ? '0' + val : val);
        } else if (val) {
            memo += val;
        }
        return memo;
    }, '');
}

function getClips(query) {
    return getTwitchJson('clips/top', query, false, 'v4').then(function (data) {
        return _.chain(data.clips)
            .groupBy(query.channel ? 'game' : 'broadcaster.name')
            .mapValues(function (clips) {
                return _.map(clips, function (clip) {
                    return {
                        title: clip.title,
                        created: moment(clip.created_at).fromNow(),
                        views: clip.views,
                        vod: _.get(clip, 'vod.url'),
                        url: clip.url
                    };
                });
            })
            .value();
    });
}

function getFollowing(username) {
    return getUserId(username).then(function (userId) {
        return getTwitchJson('users/' + userId + '/follows/channels/', {limit: 100});
    }).then(function (data) {
        return _.map(data.follows, 'channel._id');
    });
}

function getStreams(query, followed) {
    var url = followed ? 'streams/followed' : 'streams/';
    return getTwitchJson(url, query, followed).then(function (data) {
        return _.mapValues(_.groupBy(data.streams, 'channel.game'), function (streams) {
            return _.mapValues(_.keyBy(streams, 'channel.name'), function (stream) {
                return {
                    title: stream.channel.status,
                    viewers: stream.viewers,
                    uptime: moment(stream.created_at).fromNow(true),
                    quality: stream.video_height + 'p' + (Math.round(stream.average_fps / 10) * 10)
                };
            });
        });
    });
}

function getTwitchJson(path, query, oauth, api) {
    var promises = [getClientId()];
    if (oauth) {
        promises.push(getOauthToken());
    }
    return Promise.all(promises).spread(function (clientId, oauthToken) {
        var headers = {
            'Accept': 'application/vnd.twitchtv.' + (api || 'v5') + '+json',
            'Client-ID': clientId
        };
        if (oauth) {
            headers.Authorization = 'OAuth ' + oauthToken;
        }
        return makeRequest({
            headers: headers,
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
    var promise = query.channel ? getUserId(query.channel) : Promise.resolve();
    return promise.then(function (userId) {
        return getTwitchJson(userId ? 'channels/' + userId + '/videos' : 'videos/top', query)
            .then(function (data) {
                return _.chain(data[userId ? 'videos' : 'vods'])
                    .groupBy(userId ? 'game' : 'channel.name')
                    .mapValues(function (vods) {
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
                    })
                    .value();
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
    .option('-l, --limit <limit>', 'Maximum number of objects in array. Default is 25. Maximum is 100.')
    .option('-d, --debug', 'Turn on http request debugging')
    .option('-g, --game <game>', 'Streams categorized under GAME');

program
    .command('clips [channel]')
    .alias('c')
    .description('get clips by channel or by game')
    .option('-p, --period <period>', 'Period', 'month')
    .action(function (channel, options) {
        if (channel || program.game) {
            var query = _.assign(_.pick(program, 'game', 'limit'), {
                channel: channel,
                period: options.period
            });
            if (program.debug) {
                require('request-debug')(request, inspect);
            }
            getClips(query)
                .then(prettyPrint)
                .catch(logError);
        } else {
            program.help();
        }
    });

program
    .command('followed-streams')
    .alias('fs')
    .description('get live followed streams')
    .option('-t, --type <type>', 'Stream type', 'live')
    .action(function (options) {
        var query = _.assign(_.pick(program, 'game', 'limit'), {
            stream_type: options.type
        });
        if (program.debug) {
            require('request-debug')(request, inspect);
        }
        getStreams(query, true)
            .then(prettyPrint)
            .catch(logError);
    });

program
    .command('vods [channel]')
    .alias('v')
    .description('get vods by channel or by game')
    .option('-t, --type <type>', 'Broadcast type', 'archive')
    .action(function (channel, options) {
        if (channel || program.game) {
            var query = _.assign(_.pick(program, 'game', 'limit'), {
                broadcast_type: options.type,
                channel: channel
            });
            if (program.debug) {
                require('request-debug')(request, inspect);
            }
            getVods(query)
                .then(prettyPrint)
                .catch(logError);
        } else {
            program.help();
        }
    });

program
    .command('streams [username]')
    .alias('s')
    .description('get live streams by username (follows) or game')
    .option('-t, --type <type>', 'Stream type', 'live')
    .action(function (username, options) {
        if (username || program.game) {
            var query = _.assign(_.pick(program, 'game', 'limit'), {
                stream_type: options.type
            });
            if (program.debug) {
                require('request-debug')(request, inspect);
            }
            var promise = username ? getFollowing(username).then(function (channels) {
                query.channel = _.join(channels);
                return query;
            }) : Promise.resolve(query);
            promise
                .then(getStreams)
                .then(prettyPrint)
                .catch(logError);
        } else {
            program.help();
        }
    });

program.parse(process.argv);

if (_.isEmpty(_.drop(process.argv, 2))) {
    program.help();
}
