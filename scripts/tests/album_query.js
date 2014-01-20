#!/usr/bin/env node

var request = require('request'),
  _ = require('underscore');

request('http://ws.spotify.com/search/1/album.json?q=OK%20Computer', function (error, response, body) {
  body = JSON.parse(body).albums.slice(0, 10);
  body = _.map(body, function (i) {
    i.id = i.href.split(':')[2]
    i.artist = i.artists[0].name;
    return _.pick(i, 'name', 'id', 'artist');
  });
  console.log(body);
});
