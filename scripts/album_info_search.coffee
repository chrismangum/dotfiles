#!/usr/bin/env coffee
_ = require 'underscore'
async = require 'async'
fs = require 'fs'
os = require 'os'
readline = require 'readline'
request = require 'request'
util = require 'util'

rl = readline.createInterface
  input: process.stdin
  output: process.stdout

logAlbumInfo = (album) ->
  console.log 'Album: ' + album.name
  console.log 'Artist: ' + album.artist

stepPrompt = (arr, callback) ->
  async.detectSeries arr,
    ((item, callback) ->
      logAlbumInfo item
      rl.question 'Is this correct? (y, n): ', (res) ->
        callback res.toLowerCase() is 'y'
    ),
    (result) ->
      rl.pause()
      if result
        callback null, result
      else
        callback 'No more items'

parseAlbumSearch = (body) ->
  items = JSON.parse(body).albums.slice 0, 10
  _.map items, (item) ->
    item.id = item.href.split(':')[2]
    item.artist = item.artists[0].name
    _.pick item, 'name', 'id', 'artist'

parseAlbumLookup = (body) ->
  album = JSON.parse(body).album
  album.tracks = _.map album.tracks, (track, index) ->
    index += 1
    index = if index < 10 then '0' + index else index
    name: track.name
    index: index
    oldName: "track #{ index }.cdda.flac"
    newName: "\"#{ index } #{ track.name }.flac\""
  _.pick album, 'name', 'artist', 'released', 'tracks'

genTagCmds = (album) ->
  cmds = [
    genTagCmd 'DATE', album.released, '*.flac'
    genTagCmd 'ALBUM', album.name, '*.flac'
    genTagCmd 'ARTIST', album.artist, '*.flac'
  ]
  _.each album.tracks, (track) ->
    cmds.push genTagCmd 'TRACKNUMBER', track.index, track.oldName
    cmds.push genTagCmd 'TITLE', track.name, track.oldName
  cmds

genTagCmd = (tagname, value, filename) ->
  "metaflac --set-tag=\"#{ tagname }=#{ value }\" #{ filename }"

getCommandText = (album) ->
  folder = "~/media/music/\"#{ album.artist }\"/\"#{ album.name }\""
  cmds = genTagCmds album
  _.each album.tracks, (track) ->
    cmds.push "mv #{ track.oldName } #{ track.newName }"
  cmds.push 'mkdir -p ' + folder
  cmds.push 'mv *.flac ' + folder
  cmds.join(os.EOL) + os.EOL

insertNullArg = (callback) -> ->
  args = _.toArray arguments
  args.unshift null
  callback.apply this, args

async.waterfall [
  ((callback) -> rl.question 'Enter Album Query: ', insertNullArg callback),
  ((res, callback) ->
    request 'http://ws.spotify.com/search/1/album.json?q=' + res, callback
  ),
  ((res, body, callback) -> stepPrompt parseAlbumSearch(body), callback),
  ((res, callback) ->
    request 'http://ws.spotify.com/lookup/1/.json?extras=track&uri=spotify:album:' +
      res.id, callback
  ),
  (res, body, callback) ->
    fs.writeFile './command', getCommandText(parseAlbumLookup(body)), callback
], (err) ->
    console.log err or 'Done'
