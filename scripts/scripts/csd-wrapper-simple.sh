#!/bin/bash
#
# CSD wrapper script for OpenConnect.
#
# intended to be invoked by ifup with at least these variables:
#    cafile ....             # file with CA cert
#    os ....                 # os type (i.e. linux-64)
#
# if not using ifup, pass IF_CAFILE and IF_OS via env or set here
#
# response from server will be logged via syslog
#

IF_CAFILE=${IF_CAFILE:-/etc/openconnect/cisco-root-CA-M1.pem}
IF_OS=${IF_OS:-linux-64}

function run_curl {
  curl -v --silent \
    --user-agent "Open AnyConnect VPN Agent" \
    --cacert ${IF_CAFILE} \
    --header "X-Transcend-Version: 1" \
    --header "X-Aggregate-Auth: 1" \
    --header "X-AnyConnect-Platform: ${IF_OS}" \
    --cookie "sdesktop=${CSD_TOKEN}" \
    "$@" | logger -i -t csd-wrapper
}

set -e

run_curl --data-ascii @- "https://${CSD_HOSTNAME}/+CSCOE+/sdesktop/scan.xml?reusebrowser=1" <<-END
endpoint.os.version="Linux";
END

exit 0
