#!/usr/bin/env node

var  _ = require('underscore'),
  fs = require('fs'),
  os = require('os'),
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

function getCommandText(album) {
  var commands, folder;
  album = parseAlbumLookup(album);
  folder = '/media/external/music/iTunes/Music/"' +
    album.artist + '"/"' + album.name + '"';
  commands = [
    'metaflac --set-tag="DATE=' + album.released + '" *.flac',
    'mkdir -p ' + folder
  ];
  commands = commands.concat(_.map(album.tracks, function (item, i) {
    i += 1;
    i = i < 10 ? '0' + i : i;
    return 'mv track' + i + '.flac ' +
     folder + '/"' + i + ' ' + item + '.flac"';
  }));
  return commands.join(os.EOL) + os.EOL;
}

function insertNullArg(callback) {
  return function () {
    var args = _.toArray(arguments);
    args.unshift(null);
    callback.apply(this, args);
  };
}

async.waterfall([
  function (callback) {
    rl.question('Enter Album Query: ', insertNullArg(callback));
  },
  function (res, callback) {
    request('http://ws.spotify.com/search/1/album.json?q=' + res, callback);
  },
  function (res, body, callback) {
    stepPrompt(parseAlbumSearch(body), logAlbumInfo, callback);
  },
  function (res, callback) {
    request('http://ws.spotify.com/lookup/1/.json?extras=track&uri=spotify:album:' + res.id, callback);
  },
  function (res, body, callback) {
    fs.writeFile('./command', getCommandText(body), callback);
  }
], function (err) {
    console.log(err || 'Done');
  }
);
