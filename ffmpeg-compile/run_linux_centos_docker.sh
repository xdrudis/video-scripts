#!/bin/bash

#
# Verify build-ffmpeg.sh works on CentOS from scratch
#

docker run -v $(pwd):/root/tmp centos:8 /bin/sh -c '
   yum update -y && yum -y install curl git autoconf automake cmake freetype-devel gcc gcc-c++ git libtool make pkgconfig zlib-devel openssl-devel diffutils fribidi-devel
   /bin/bash -x /root/tmp/build-ffmpeg.sh
'
