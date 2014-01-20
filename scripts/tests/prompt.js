#!/usr/bin/env node

var request = require('request'),
  _ = require('underscore'),
  util = require('util'),
  readline = require('readline');

var items,
  i = 0,
  rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout
  });

function prompt(item, callback) {
  console.log('Album: ' + item.name);
  console.log('Artist: ' + item.artist);
  rl.question('Is this correct? (y, n): ', function (res) {
    if (/y/i.test(res)) {
      rl.close();
      callback(items[i]);
    } else if (items[i += 1]) {
      prompt(items[i], callback);
    } else {
      rl.close();
      console.log('No more items.');
    }
  });
}

request('http://ws.spotify.com/search/1/album.json?q=OK Computer', function (error, response, body) {
  body = JSON.parse(body).albums.slice(0, 10);
  body = _.map(body, function (i) {
    i.id = i.href.split(':')[2]
    i.artist = i.artists[0].name;
    return _.pick(i, 'name', 'id', 'artist');
  });
  items = body;
  prompt(items[i], function (sel) {
    console.log('The selected item was: ' + util.inspect(sel));
  });
});
