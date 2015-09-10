#!/bin/bash

function echoLines() {
  for i in $(seq 1 $1); do
    echo "XxXxXxXxXxXxXxXxXxXxXxXxXxXxXxXxXxXxXxXxXxXxXxXxXxXxXxXxXxXxXxXxXxXxXxXxXxXxXxXxXxXxXxXxXx $i"
  done
}

echoLines $@
