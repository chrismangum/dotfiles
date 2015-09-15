#!/usr/bin/python3
import json
import sys
from datetime import datetime, timezone
from urllib import request

BASEURL = 'https://api.twitch.tv/kraken'
HEADERS = {'Accept:': 'application/vnd.twitchtv.v3+json'}

def getFollowing(username):
    data = getTwitchJSON('/users/' + username + '/follows/channels/?limit=100')
    return [ch['channel']['name'] for ch in data['follows']]

def getLiveChannels(channelNames):
    data = getTwitchJSON('/streams/?channel=' + ','.join(channelNames))
    channels = {}
    for ch in data['streams']:
        channels[ch['channel']['name']] = {
            'game': ch['channel']['game'],
            'title': ch['channel']['status'],
            'viewers': ch['viewers'],
            'live_since': datetime.strptime(ch['created_at'], '%Y-%m-%dT%XZ') \
                .replace(tzinfo=timezone.utc).astimezone() \
                .strftime('%c')
        }
    return channels

def getTwitchJSON(path):
    return json.loads(httpGet(BASEURL + path, HEADERS))

def httpGet(url, headers):
    req = request.Request(url, headers=headers)
    return request.urlopen(req).readall().decode('utf-8')

def prettyPrint(data):
    return json.dumps(data, indent=2)

if (len(sys.argv) > 1):
    liveChannels = getLiveChannels(getFollowing(sys.argv[1]))
    out = 'Found ' + str(len(liveChannels)) + ' live channels'
    if (len(liveChannels)):
        out += ': ' + prettyPrint(liveChannels)
    print(out)
else:
    print('Please supply a twitch username.')
    sys.exit(1)
