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
      if (!result) {
        callback('No more items');
      } else {
        callback(null, result);
      }
    }
  );
}

function parseAlbumSearch(body) {
  var items = JSON.parse(body).albums.slice(0, 10);
  return _.map(items, function (i) {
    i.id = i.href.split(':')[2];
    i.artist = i.artists[0].name;
    return _.pick(i, 'name', 'id', 'artist');
  });
}

function parseAlbumLookup(body) {
  var album = JSON.parse(body).album;
  album.tracks = _.map(album.tracks, function (i) {
    return i.name;
  });
  return _.pick(album, 'name', 'artist', 'released', 'tracks');
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
    stepPrompt(parseAlbumSearch(body), logAlbumInfo, callback);
  },
  function (res, callback) {
    request('http://ws.spotify.com/lookup/1/.json?extras=track&uri=spotify:album:' + res.id, callback);
  }
], function (err, result, body) {
    console.log(err || parseAlbumLookup(body));
  }
);


