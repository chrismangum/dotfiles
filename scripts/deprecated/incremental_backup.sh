#!/bin/bash

#backup files that have changed within the past 24 hours:

cd ~/www
filename=$(date +"%m-%d-%y")_inc.tar
find . -mtime 0 -type f -not -path "*/cache/*" | sed 's/ /\\ /g' | grep -v "error_log$" | xargs tar -cf $filename
mv $filename ~/backups
