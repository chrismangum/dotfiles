#!/usr/bin/env node

var callback;
process.stdin.on('data', function (res) {
  process.stdin.pause();
  callback(res);
});

function prompt(prompt, cback) {
  callback = cback;
  process.stdout.write(prompt);
  process.stdin.resume();
}

prompt('Is this correct? (y, n): ', function (res) {
  console.log(/y\n/i.test(res) ? 'Ok' : 'Aborting');
});


