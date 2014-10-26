_ = require 'underscore'
fs = require 'fs'
exec = require('child_process').exec
moment = require 'moment'
chokidar = require 'chokidar'

watches = [
  path: 'WebContent/'
  remotePath: ''
  excludes: []
,
  path: process.env.APOLLO_BASE_DIR + '/common/client/js/'
  remotePath: 'js/app/common/'
  excludes: [/vendor/, /.coffee$/]
,
  path: process.env.APOLLO_BASE_DIR + '/common/client/css/'
  remotePath: 'css/'
  excludes: []
,
  path: process.env.APOLLO_BASE_DIR + '/common/client/js/vendor/'
  remotePath: 'js/'
  excludes: []
]

if process.cwd().split('/').pop() is 'ciscoAdmin'
  stackatoAppId = 'ciscoAdmin'
else
  appDescriptor = JSON.parse fs.readFileSync('appDescriptor.json').toString()
  version = fs.readFileSync('version.txt').toString().replace '\n', ''
  stackatoAppId = [
    appDescriptor.appId
    version.replace /\./g, '-'
    moment().format 'YYYYMM'
    process.env.USER
  ].join '-'

log = (msg) ->
  process.stdout.write msg

syncFile = (src, dest) ->
  log "Updating file: #{ src.replace process.env.HOME, '~' } ... "
  exec "stackato scp -a #{ stackatoAppId } #{ src } :#{ dest }",
    (err, stdout, stderr) ->
      if err
        console.log 'Error:'
        log stdout + stderr
      else
        console.log 'Done.'

_.each watches, (watch) ->
  #ignore swap files
  watch.excludes.push /.swp$/
  chokidar
    .watch watch.path, persistent: true
    .on 'change', (path) ->
      excluded = _.some watch.excludes, (exclude) ->
        path.match exclude
      unless excluded
        dest = watch.remotePath + path.replace watch.path, ''
        syncFile path, dest
