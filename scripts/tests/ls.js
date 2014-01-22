#!/usr/bin/env node

var fs = require('fs'),
  _ = require('underscore');

var files,
  sort = false,
  permissions = {
    '0': '---',
    '4': 'r--',
    '5': 'r-x',
    '6': 'rw-',
    '7': 'rwx'
  },
  filetypes = {
    '120': 'l',
    '100': '-'
  };

function getPermissions(mode) {
  var filetype;
  mode = mode.toString(8);
  if (mode.length === 5) {
    filetype = 'd'
  } else {
    filetype = filetypes[mode.slice(0,3)];
  }
  mode = mode.slice(-3).split('');
  return filetype + _.map(mode, function (item) {
    return permissions[item];
  }).join('');
}

function humanReadableSize(size) {
  var count = 0,
    sizes = ['B', 'K', 'M', 'G', 'T'];
  while (size / 1024 > 1) {
    size /= 1024;
    count += 1;
  }
  size = isInt(size) ? size : size.toFixed(1);
  return size + sizes[count];
}

function isInt(n) {
  return n % 1 === 0;
}

files = fs.readdirSync(process.cwd());

files = _.map(files, function (fileName) {
  var file = fs.lstatSync('./' + fileName);
  file.name = fileName;
  return file;
});

if (sort) {
  files = _(files).sortBy(function (file) {
    return file.size * -1;
  });
}

files = _.map(files, function (file) {
  file.mode = getPermissions(file.mode);
  file.size = humanReadableSize(file.size);
  file = _.pick(file, 'mode', 'size', 'name');
  return _.toArray(file).join('\t');
});

console.log(files.join('\n'));

