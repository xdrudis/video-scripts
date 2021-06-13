FROM nvidia/cuda:11.3.1-devel-ubuntu20.04

RUN apt-get update -qq
RUN DEBIAN_FRONTEND=noninteractive apt-get -qq -y install build-essential cmake curl autoconf automake \
                 libtool git libfreetype-dev fontconfig libfontconfig1-dev libssl-dev diffutils pkg-config nasm libfribidi-dev ninja-build \
                 python3 python3-pip python3-setuptools libharfbuzz-dev libharfbuzz-icu0 \
                 vim wget

RUN pip3 install meson

ADD build-ffmpeg.sh .
RUN PREFIX=/usr/local ./build-ffmpeg.sh && rm build-ffmpeg.sh

