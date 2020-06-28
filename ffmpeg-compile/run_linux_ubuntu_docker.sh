#!/bin/bash

#
# Verify build-ffmpeg.sh works on Ubuntu from scratch
#

docker run -v $(pwd):/root/tmp ubuntu:20.04 /bin/sh -c '
   ln -fs /usr/share/zoneinfo/America/Los_Angeles /etc/localtime
   apt-get update -qq && DEBIAN_FRONTEND=noninteractive apt-get -qq -y install build-essential cmake curl autoconf automake libtool git libfreetype-dev libssl-dev diffutils pkg-config
   /bin/bash -x /root/tmp/build-ffmpeg.sh
'
