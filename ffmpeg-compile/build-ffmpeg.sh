#!/bin/bash

#
# Portable script to compile ffmpeg, with vmaf support (x86_64 only)
# Requires no root access, making it easy for multiple environments to coexist.
# Inspired by https://github.com/jrottenberg/ffmpeg, but not focused on containers.
#
# Usage: ./build-ffmpeg.sh
#

set -euo pipefail

# See https://github.com/xdrudis/video-scripts/tree/master/.github/workflows
# for a full list of packages needed for each platform.

#
# Destination folder. Ffmpeg and tools will be in $PREFIX/bin
#
PREFIX=$HOME/local

sudo=""
# Uncomment line below if writing to $PREFIX needs sudo
#sudo=sudo

# Software versions
FFMPEG_VERSION=4.3                # https://github.com/FFmpeg/FFmpeg/releases
FDKAAC_VERSION=2.0.1              # https://github.com/mstorsjo/fdk-aac/releases
KVAZAAR_VERSION=2.0.0             # https://github.com/ultravideo/kvazaar/releases
LIB_VMAF_VERSION=1.5.2            # https://github.com/Netflix/vmaf/releases
X264_VERSION=296494a4             # Last commit in https://code.videolan.org/videolan/x264/-/tree/stable
X265_VERSION=3.4                  # https://github.com/videolan/x265/releases
NASM_VERSION=2.14.02              # https://www.nasm.us/pub/nasm/releasebuilds
LIBMP3LAME_VERSION=3.100          # https://sourceforge.net/projects/lame/files/lame/
LIBOPUS_VERSION=1.3.1             # https://archive.mozilla.org/pub/opus/
OPENJPEG_VERSION=2.3.1            # https://github.com/uclouvain/openjpeg/releases
LIBVPX_VERSION=de4aeda            # git commit, as latest version v1.8.2 fail to build on macOs https://github.com/webmproject/libvpx/releases
LIBWEBP_VERSION=1.1.0             # https://github.com/webmproject/libwebp/releases
LIBASS_VERSION=0.13.7             # https://github.com/libass/libass/releases
NV_CODEC_HEADERS_VERSION=9.1.23.1 # https://github.com/FFmpeg/nv-codec-headers/releases

OPENSSL=/usr/local/opt/openssl@1.1 # Needed for Mac OSX. No-op for the rest
export PKG_CONFIG_PATH=$PREFIX/lib/pkgconfig:$PREFIX/lib/$HOSTTYPE-$OSTYPE/pkgconfig:$PREFIX/lib64/pkgconfig:${OPENSSL}/lib/pkgconfig:${PKG_CONFIG_PATH:-} # https://stackoverflow.com/a/29792635
export LD_LIBRARY_PATH=$PREFIX/lib:$PREFIX/lib64:${LD_LIBRARY_PATH:-}
PATH="${PREFIX}/bin:$HOME/.local/bin:$PATH"

ncores=$(nproc 2> /dev/null || sysctl -n hw.ncpu 2> /dev/null || echo 4)
njobs=$(( $ncores * 3 / 2 )) # 1.5 number of cores

TMPDIR=$(mktemp -d)

cleanup() {
    status=$?
    [ $status -eq 0 ] || echo -e "\n☠️ ☠️ ☠️  Script failed (status $status)\n"
    rm -fR "$TMPDIR"
    exit $status
}
trap cleanup INT TERM EXIT

#
# nasm
#
if nasm -version 2> /dev/null | grep " $NASM_VERSION " 2> /dev/null ; then
   echo "nasm $NASM_VERSION version already available. Picking system version"
else
   DIR=$TMPDIR/nasm; mkdir -p "$DIR"; cd "$DIR"
   curl -sL https://www.nasm.us/pub/nasm/releasebuilds/${NASM_VERSION}/nasm-${NASM_VERSION}.tar.gz | tar xz --strip-components=1
   ./configure --prefix="$PREFIX"
   make -j$njobs
   $sudo make install
   rm -fR "$DIR"
fi

#
# libass
#
DIR=$TMPDIR/libass; mkdir -p "$DIR"; cd "$DIR"
curl -sL https://github.com/libass/libass/archive/${LIBASS_VERSION}.tar.gz | tar xz --strip-components=1
./autogen.sh
./configure --prefix="$PREFIX" --disable-static --enable-shared
make -j$njobs
$sudo make install
rm -fR "$DIR"

#
# fdk-aac
#
DIR=$TMPDIR/fdk-aac; mkdir -p "$DIR"; cd "$DIR"
curl -sL https://github.com/mstorsjo/fdk-aac/archive/v${FDKAAC_VERSION}.tar.gz | tar xz --strip-components=1
autoreconf -fiv
./configure --prefix="$PREFIX" --enable-shared --datadir="$DIR"
make -j$njobs
$sudo make install
rm -fR "$DIR"

#
# kvazaar
#
DIR=$TMPDIR/kvazaar; mkdir -p "$DIR"; cd "$DIR"
curl -sL https://github.com/ultravideo/kvazaar/archive/v${KVAZAAR_VERSION}.tar.gz | tar xz --strip-components=1
./autogen.sh
./configure --prefix="$PREFIX" --disable-static --enable-shared
make -j$njobs
$sudo make install
rm -fR "$DIR"

if [[ "$HOSTTYPE" == x86_64 ]] ; then
   #
   # libvmaf
   #
   DIR=$TMPDIR/vmaf; mkdir -p "$DIR"; cd "$DIR"
   curl -sL https://github.com/Netflix/vmaf/archive/v${LIB_VMAF_VERSION}.tar.gz | tar xz --strip-components=1
   meson setup libvmaf libvmaf/build --buildtype release --prefix="$PREFIX"
   $sudo ninja -vC libvmaf/build install
   rm -fR "$DIR"

   VMAF="--enable-libvmaf"
else
   VMAF=""
fi

#
# libmp3lame
#
DIR=$TMPDIR/libmp3lame; mkdir -p "$DIR"; cd "$DIR"
curl -sL https://downloads.sourceforge.net/project/lame/lame/${LIBMP3LAME_VERSION}/lame-${LIBMP3LAME_VERSION}.tar.gz | tar xz --strip-components=1
[[ "$OSTYPE" == darwin* ]] && cp include/libmp3lame.sym include/libmp3lame.sym.bak && sed '/lame_init_old/d' include/libmp3lame.sym.bak > include/libmp3lame.sym # see https://stackoverflow.com/a/53955675
./configure --prefix="$PREFIX" --enable-shared --enable-nasm
make -j$njobs
$sudo make install
rm -fR "$DIR"

#
# OpenJPEG
#
DIR=$TMPDIR/openjpeg; mkdir -p "$DIR"; cd "$DIR"
curl -sL https://github.com/uclouvain/openjpeg/archive/v${OPENJPEG_VERSION}.tar.gz | tar xz --strip-components=1
mkdir build
cd build
cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$PREFIX" ..
make -j$njobs
$sudo make install
rm -fR "$DIR"

#
# libopus
#
DIR=$TMPDIR/libopus; mkdir -p "$DIR"; cd "$DIR"
curl -sL https://archive.mozilla.org/pub/opus/opus-${LIBOPUS_VERSION}.tar.gz | tar xz --strip-components=1
./configure --prefix="$PREFIX" --enable-shared
make -j$njobs
$sudo make install
rm -fR "$DIR"

#
# x264
#
DIR=$TMPDIR/x264; mkdir -p "$DIR"; cd "$DIR"
curl -sL https://code.videolan.org/videolan/x264/-/archive/master/x264-${X264_VERSION}.tar.gz | tar xz --strip-components 1
./configure --prefix="$PREFIX" --enable-static --enable-pic
make -j$njobs
$sudo make install-lib-static
rm -fR "$DIR"

#
# x265
#
DIR=$TMPDIR/x265; mkdir -p "$DIR"; cd "$DIR"
curl -sL https://github.com/videolan/x265/archive/${X265_VERSION}.tar.gz | tar xz --strip-components 1
cd build/linux
cmake -G "Unix Makefiles" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$PREFIX" ../../source
make -j$njobs
$sudo make install
rm -fR "$DIR"

#
# libvpx
#
DIR=$TMPDIR/libvpx; mkdir -p "$DIR"; cd "$DIR"
curl -sL https://github.com/webmproject/libvpx/tarball/${LIBVPX_VERSION} | tar xz --strip-components 1
./configure --prefix="$PREFIX" --as=nasm --disable-dependency-tracking --disable-examples --disable-unit-tests --enable-pic --enable-vp9-highbitdepth
make -j$njobs
$sudo make install
rm -fR "$DIR"

#
# webp
#
DIR=$TMPDIR/libwebp; mkdir -p "$DIR"; cd "$DIR"
curl -sL https://storage.googleapis.com/downloads.webmproject.org/releases/webp/libwebp-${LIBWEBP_VERSION}.tar.gz | tar xz --strip-components 1
./configure --prefix="$PREFIX" --enable-libwebpdecoder --enable-libwebpdemux --enable-libwebpmux 
make -j$njobs
$sudo make install
rm -fR "$DIR"

if [ -r /usr/local/cuda ] ; then
   #
   # Nvidia codec headers
   #
   DIR=$TMPDIR/nv-codec-headers; mkdir -p "$DIR"; cd "$DIR"
   curl -sL https://github.com/FFmpeg/nv-codec-headers/archive/n${NV_CODEC_HEADERS_VERSION}.tar.gz | tar xz --strip-components 1
   cp Makefile Makefile.bak ; sed "s;/usr/local;$PREFIX;" Makefile.bak > Makefile
   make -j$njobs
   $sudo make install
   rm -fR "$DIR"
   CUDA="--enable-nvenc --enable-cuda --enable-cuvid --enable-libnpp"
   CUDA_LD_LIBRARY_PATH=":/usr/local/cuda/targets/x86_64-linux/lib"
else
   CUDA=""
   CUDA_LD_LIBRARY_PATH=""
fi

#
# ffmpeg
#
DIR=$TMPDIR/ffmpeg; mkdir -p "$DIR"; cd "$DIR"
curl -sL https://ffmpeg.org/releases/ffmpeg-${FFMPEG_VERSION}.tar.gz | tar xz --strip-components=1
./configure \
   --disable-debug \
   --disable-doc \
   --enable-ffplay \
   --disable-shared \
   --enable-avresample \
   --enable-gpl \
   --enable-libfreetype \
   --enable-libmp3lame \
   --enable-libopenjpeg \
   --enable-libopus \
   --enable-libvpx \
   --enable-libx264 \
   --enable-libx265 \
   --enable-nonfree \
   --enable-openssl \
   --enable-libfdk_aac \
   --enable-libkvazaar \
   --extra-libs=-lpthread \
   --enable-postproc \
   --enable-small \
   $VMAF \
   $CUDA \
   --enable-indev=alsa \
   --enable-outdev=alsa \
   --enable-version3 \
   --enable-libwebp \
   --enable-libass \
   --enable-fontconfig \
   --extra-cflags="-I${PREFIX}/include -I${PREFIX}/include/ffnvcodec -I/usr/local/cuda/include/" \
   --extra-ldflags="-L${PREFIX}/lib -L${OPENSSL}/lib -L/usr/local/cuda/lib64" \
   --extra-libs="-ldl -lm" \
   --prefix="$PREFIX" || ( cat ffbuild/config.log ; exit 1 )
make -j$njobs
$sudo make install
cd tools
make qt-faststart
$sudo cp qt-faststart "${PREFIX}/bin"
rm -fR "$DIR"

hash -r

echo
echo 🎉🎉🎉 Success!
echo
echo "Please run this:

echo 'export LD_LIBRARY_PATH=$PREFIX/lib:$PREFIX/lib64:$PREFIX/lib/$HOSTTYPE-$OSTYPE$CUDA_LD_LIBRARY_PATH:\$LD_LIBRARY_PATH
export PATH=$PREFIX/bin:\$PATH' >> $HOME/.bashrc"
