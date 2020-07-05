#!/bin/bash

set -euo pipefail

PREFIX=$HOME/local
TMPDIR=$(mktemp -d)

cleanup() {
    status=$?
    [ $status -eq 0 ] || echo -e "\n☠️ ☠️ ☠️  Script failed (status $status)\n"
    rm -fR "$TMPDIR"
    exit $status
}
trap cleanup INT TERM EXIT


cd $TMPDIR

curl -sLO https://media.xiph.org/video/derf/y4m/akiyo_qcif.y4m

export LD_LIBRARY_PATH=$PREFIX/lib:$PREFIX/lib64:$PREFIX/lib/$HOSTTYPE-$OSTYPE:${LD_LIBRARY_PATH:-}

$PREFIX/bin/ffmpeg -i akiyo_qcif.y4m output.mp4

if [[ "$HOSTTYPE" == x86_64 ]] ; then
   $PREFIX/bin/ffmpeg -i output.mp4 -i akiyo_qcif.y4m -lavfi "[0][1]libvmaf=model_path=$PREFIX/share/model/vmaf_v0.6.1.pkl" -f null -
fi

if [ -r /usr/local/cuda ] ; then
   $PREFIX/bin/ffmpeg -i akiyo_qcif.y4m -filter_complex 'hwupload_cuda,scale_npp=-1:288:interp_algo=lanczos,hwdownload' -c:v:0 h264_nvenc -profile:v high -bf 4 -refs 3 -rc vbr_hq output2.mp4
fi

