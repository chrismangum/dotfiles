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

function albumInfo(album) {
  var string = 'Album: ' + album.name + '\n';
  return string + 'Artist: ' + album.artist;
}

function albumStepPrompt(albums, callback) {
  async.detectSeries(albums,
    function (item, callback) {
      console.log(albumInfo(item));
      yesNoPrompt(function (res) {
        callback(/y/i.test(res));
      });
    },
    function (result) {
      rl.close();
      if (result) {
        callback(result);
      } else {
        console.log('No more items.');
      }
    }
  );
}

function yesNoPrompt(callback) {
  rl.question('Is this correct? (y, n): ', callback);
}

function parseAlbumQuery(err, res, body) {
  var items = JSON.parse(body).albums.slice(0, 10);
  items = _.map(items, function (i) {
    i.id = i.href.split(':')[2]
    i.artist = i.artists[0].name;
    return _.pick(i, 'name', 'id', 'artist');
  });
  albumStepPrompt(items, function (sel) {
    console.log('The selected item was: ' + util.inspect(sel));
  });
}

request('http://ws.spotify.com/search/1/album.json?q=OK Computer', parseAlbumQuery);

