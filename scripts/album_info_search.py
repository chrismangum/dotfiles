#! /usr/bin/python3
import json
import os
import urllib.parse
import urllib.request

def writeFile(filepath, content):
  f = open(filepath, 'w')
  f.write(content)
  f.close()

def httpGet(url):
  return urllib.request.urlopen(url).readall().decode('utf-8')

def getJSON(url):
  return json.loads(httpGet(url))

def albumSearch():
  data = getJSON('http://ws.spotify.com/search/1/album.json?' +
    urllib.parse.urlencode({'q': input('Enter Album Query: ')}))
  return list(map(lambda album: {
    'name': album['name'],
    'artist': album['artists'][0]['name'],
    'id': album['href'].split(':')[2]
  }, data['albums'][0:10]))

def albumLookup(albumID):
  data = getJSON('http://ws.spotify.com/lookup/1/.json?extras=track&uri=spotify:album:' + albumID)
  tracks = []
  album = data['album']
  for i, track in enumerate(album['tracks']):
    index = format(i + 1, '02')
    tracks.append({
      'name': track['name'],
      'index': index,
      'oldName': 'track' + index + '.cdda.flac',
      'newName': '"' + index + ' ' + track['name'] + '.flac"'
    })
  album['tracks'] = tracks
  return album

def genTagCmd(tagname, value, filename):
  return 'metaflac --set-tag="' + tagname + '=' + value + '" ' + filename

def getCommandText(album):
  folder = '~/media/music/"' +  album['artist'] + '"/"' + album['name'] + '"'
  cmds = [
    genTagCmd('DATE', album['released'], '*.flac'),
    genTagCmd('ALBUM', album['name'], '*.flac'),
    genTagCmd('ARTIST', album['artist'], '*.flac')
  ]
  for track in album['tracks']:
    cmds.append(genTagCmd('TRACKNUMBER', track['index'], track['oldName']))
    cmds.append(genTagCmd('TITLE', track['name'], track['oldName']))
    cmds.append('mv ' + track['oldName'] + ' ' + track['newName'])
  cmds.append('mkdir -p ' + folder)
  cmds.append('mv *.flac ' + folder)
  return os.linesep.join(cmds) + os.linesep

def selectAlbum(albums):
  selected = None
  for album in albums:
    print('Album: ' + album['name'])
    print('Artist: ' + album['artist'])
    if input('Is this correct? (y, n): ').lower() == 'y':
      selected = album
      break
  if not selected:
    print('No more items.')
  return selected

selected = selectAlbum(albumSearch())
if selected:
  album = albumLookup(selected['id'])
  writeFile('command', getCommandText(album))
  print('Done.')
