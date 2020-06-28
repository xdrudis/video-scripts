#!/bin/bash

#
# Verify build-ffmpeg.sh works on Alpine Linux from scratch
#

docker run -v $(pwd):/root/tmp -i alpine:3.7 /bin/sh -c '
   apk update && apk add --virtual build-dependencies build-base gcc bash cmake curl autoconf automake libtool git freetype-dev openssl-dev diffutils
   /bin/bash -x /root/tmp/build-ffmpeg.sh
'
