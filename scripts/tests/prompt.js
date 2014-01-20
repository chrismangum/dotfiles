#!/usr/bin/env node

var  _ = require('underscore'),
  util = require('util'),
  async = require('async'),
  request = require('request'),
  readline = require('readline');

var rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout
});

function logAlbumInfo(album) {
  console.log(
    'Album: ' + album.name + '\n' +
    'Artist: ' + album.artist
  );
}

function stepPrompt(arr, logger, callback) {
  async.detectSeries(arr,
    function (item, callback) {
      logger(item);
      rl.question('Is this correct? (y, n): ', function (res) {
        callback(/y/i.test(res));
      });
    },
    function (result) {
      rl.pause();
      callback(result);
    }
  );
}

function parseAlbumQuery(body) {
  var items = JSON.parse(body).albums.slice(0, 10);
  return _.map(items, function (i) {
    i.id = i.href.split(':')[2];
    i.artist = i.artists[0].name;
    return _.pick(i, 'name', 'id', 'artist');
  });
}

function insertNull(callback) {
  return function (res) {
    var args = _.toArray(arguments);
    args.unshift(null);
    callback.apply(this, args);
  };
}

async.waterfall([
  function (callback) {
    rl.question('Enter Album Query: ', insertNull(callback));
  },
  function (res, callback) {
    request('http://ws.spotify.com/search/1/album.json?q=' + res, callback);
  },
  function (res, body, callback) {
    stepPrompt(parseAlbumQuery(body), logAlbumInfo, insertNull(callback));
  }
], function (err, sel) {
  console.log(err || sel ? 'The selected item was: ' + util.inspect(sel) : 'No more items.');
});


