FROM nvidia/cuda:11.3.1-devel-ubuntu20.04

RUN apt-get update -qq
RUN DEBIAN_FRONTEND=noninteractive apt-get -qq -y install build-essential cmake curl autoconf automake \
                 libtool git libfreetype-dev fontconfig libssl-dev diffutils pkg-config nasm libfribidi-dev ninja-build \
                 python3 python3-pip python3-setuptools vim wget

RUN apt-get -qq -y install libharfbuzz-dev libharfbuzz-icu0 libfontconfig1-dev

RUN pip3 install meson

ADD build-ffmpeg.sh .
RUN PREFIX=/usr/local ./build-ffmpeg.sh

