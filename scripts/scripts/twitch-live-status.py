#!/usr/bin/python3
import argparse
import json
from datetime import datetime, timezone
from urllib import parse, request

def getFollowing(username):
    data = getTwitchJSON('/users/' + username + '/follows/channels/?limit=100')
    return [ch['channel']['name'] for ch in data['follows']]

def getLiveChannels(query):
    data = getTwitchJSON('/streams/?' + parse.urlencode(query))
    channels = []
    for ch in data['streams']:
        channel = {
            'name': ch['channel']['name'],
            'title': ch['channel']['status'],
            'viewers': ch['viewers'],
            'live_since': datetime.strptime(ch['created_at'], '%Y-%m-%dT%XZ') \
                .replace(tzinfo=timezone.utc).astimezone() \
                .strftime('%c')
        }
        if not args.game:
            channel['game'] = ch['channel']['game']
        channels.append(channel)
    return channels

def getTwitchJSON(path):
    return json.loads(httpGet('https://api.twitch.tv/kraken' + path, {
        'Accept': 'application/vnd.twitchtv.v3+json'
    }))

def httpGet(url, headers):
    req = request.Request(url, headers=headers)
    return request.urlopen(req).read().decode('utf-8')

def prettyPrint(data):
    return json.dumps(data, indent=2, ensure_ascii=False)

def printLiveChannels(liveChannels):
    count = len(liveChannels)
    out = 'Found ' + str(count) + ' live channel'
    if count == 0 or count > 1:
        out += 's'
    if count:
        out += ': ' + prettyPrint(liveChannels)
    print(out)

parser = argparse.ArgumentParser()
parser.add_argument('-g', '--game', help='Streams categorized under GAME')
parser.add_argument('-u', '--username', help='Username to query live followed streams')
parser.add_argument('-l', '--limit', help='Maximum number of objects in array. Default is 25. Maximum is 100.')
args = parser.parse_args()

if args.game or args.username:
    query = {'stream_type': 'live'}
    if args.game:
        query['game'] = args.game
    if args.username:
        query['channel'] = ','.join(getFollowing(args.username))
    if args.limit:
        query['limit'] = args.limit
    printLiveChannels(getLiveChannels(query))
else:
    parser.print_help()
