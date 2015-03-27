#!/bin/bash
set -e

cd ~/Cisco/ApolloSAStandalone
gulp --sa $@ --linux64
cd build/standalone/build/ASA-CLI-Analyzer/linux64/
./'ASA CLI Analyzer'
