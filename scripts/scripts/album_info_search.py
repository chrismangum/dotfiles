#!/usr/bin/python3
import json
import os
import sys
from urllib.parse import urlencode
from urllib.request import urlopen

def writeFile(filepath, content):
    f = open(filepath, 'w')
    f.write(content)
    f.close()

def httpGet(url):
    return urlopen(url).read().decode('utf-8')

def getJSON(url):
    return json.loads(httpGet(url))

def albumSearch():
    data = getJSON('https://api.spotify.com/v1/search?' + urlencode({
        'q': input('Enter Album Query: '),
        'type': 'album'
    }))
    return [album['id'] for album in data['albums']['items'][0:10]]

def albumLookup(albumId):
    data = getJSON('https://api.spotify.com/v1/albums/' + albumId)
    album = {
        'name': data['name'],
        'release_date': data['release_date'],
        'artist': data['artists'][0]['name']
    }
    tracks = []
    for track in data['tracks']['items']:
        track_number = format(track['track_number'], '02')
        tracks.append({
            'name': track['name'],
            'track_number': track_number,
            'filename': '"' + track_number + ' ' + track['name']
        })
    album['tracks'] = tracks
    return album

preCommands = {
    'flac': 'metaflac --remove-all-tags *.flac',
    'm4a': 'mp4tags -r R *.m4a',
    'mp3': 'id3v2 -d *.mp3'
}

tags = {
    'flac': {
        'album': 'ALBUM',
        'artist': 'ARTIST',
        'song': 'TITLE',
        'track': 'TRACKNUMBER',
        'year': 'DATE'
    },
    'm4a': {
        'album': 'album',
        'artist': 'artist',
        'song': 'song',
        'track': 'track',
        'year': 'year'
    },
    'mp3': {
        'album': 'album',
        'artist': 'artist',
        'song': 'song',
        'track': 'track',
        'year': 'year'
    }
}

def genTagCmd(ext, tag, value, filename):
    if ext == 'flac':
        return 'metaflac --set-tag="' + tags[ext][tag] + '=' + value + '" ' + filename
    elif ext == 'm4a':
        return 'mp4tags -' + tags[ext][tag] + ' "' + value + '" ' + filename
    elif ext == 'mp3':
        return 'id3v2 --' + tags[ext][tag] + ' "' + value + '" ' + filename

def getCommandText(album):
    ext = promptExtension()
    mvCommands = input('Include mv commands? (y, n): ').lower() == 'y'
    wildcard = '*.' + ext
    folder = '~/media/music/"' + album['artist'] + '"/"' + album['name'] + '"'
    cmds = [
        preCommands[ext],
        genTagCmd(ext, 'year', album['release_date'], wildcard),
        genTagCmd(ext, 'album', album['name'], wildcard),
        genTagCmd(ext, 'artist', album['artist'], wildcard)
    ]
    for track in album['tracks']:
        track['filename'] += '.' + ext + '"'
        if mvCommands:
            cmds.append('mv track' + track['track_number'] + '.cdda.' + ext + ' ' + track['filename'])
        cmds += [
            genTagCmd(ext, 'track', track['track_number'], track['filename']),
            genTagCmd(ext, 'song', track['name'], track['filename'])
        ]
    if mvCommands:
        cmds += ['mkdir -p ' + folder, 'mv '+ wildcard + ' ' + folder]
    return os.linesep.join(cmds) + os.linesep

def promptExtension():
    types = ['flac', 'm4a', 'mp3']
    res = input('Extension (flac / m4a / mp3)? ')
    if res in types:
        return res
    else:
        print('Unsupported response.')
        sys.exit(1)

def selectAlbum(albumIds):
    selected = None
    for albumId in albumIds:
        album = albumLookup(albumId)
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
    writeFile('commands', getCommandText(selected))
    print('Done.')
