#!/usr/bin/env node

var request = require('request'),
  _ = require('underscore'),
  util = require('util'),
  readline = require('readline'),
  async = require('async');

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

function albumStepPrompt(albums, callback) {
  async.detectSeries(albums,
    function (item, callback) {
      logAlbumInfo(item);
      yesNoPrompt(callback);
    },
    function (result) {
      rl.close();
      callback(result);
    }
  );
}

function yesNoPrompt(callback) {
  rl.question('Is this correct? (y, n): ', function (res) {
    callback(/y/i.test(res));
  });
}

function parseAlbumQuery(err, res, body) {
  var items = JSON.parse(body).albums.slice(0, 10);
  items = _.map(items, function (i) {
    i.id = i.href.split(':')[2]
    i.artist = i.artists[0].name;
    return _.pick(i, 'name', 'id', 'artist');
  });
  albumStepPrompt(items, function (sel) {
    console.log(sel ? 'The selected item was: ' + util.inspect(sel) : 'No more items.');
  });
}

rl.question('Enter Album Query: ', function(res) {
  request('http://ws.spotify.com/search/1/album.json?q=' + res, parseAlbumQuery);
});

