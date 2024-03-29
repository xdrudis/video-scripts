#!/bin/bash

set -euo pipefail

PREFIX=${PREFIX:-$HOME/local}
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

export LD_LIBRARY_PATH=$PREFIX/lib:${LD_LIBRARY_PATH:-}

$PREFIX/bin/ffmpeg -i akiyo_qcif.y4m -c:v libx264 -vf "drawtext=text='text test':fontcolor=white:fontsize=24:box=1:boxcolor=black@0.5:boxborderw=5:x=20:y=20" output-h264.mp4
$PREFIX/bin/ffmpeg -i akiyo_qcif.y4m -c:v libsvtav1 test.ivf
$PREFIX/bin/ffmpeg -i akiyo_qcif.y4m -c:v libx265 output-h265.mp4
$PREFIX/bin/ffmpeg -i akiyo_qcif.y4m -c:v libvpx-vp9 output-vp9.webm

if [[ "$HOSTTYPE" == x86_64 ]] ; then
   $PREFIX/bin/ffmpeg -i output-h264.mp4 -i akiyo_qcif.y4m -lavfi "[0][1]libvmaf=model_path=$PREFIX/share/model/vmaf_v0.6.1.json" -f null -
fi

if [ -r /usr/local/cuda ] ; then
   # $PREFIX/bin/ffmpeg -i akiyo_qcif.y4m -filter_complex 'hwupload_cuda,scale_npp=-1:288:interp_algo=lanczos,hwdownload' -c:v:0 h264_nvenc -profile:v high -bf 4 -refs 3 -rc vbr_hq output2.mp4
   # See ffmpeg -h encoder=h264_nvenc
   $PREFIX/bin/ffmpeg -hwaccel cuvid -i akiyo_qcif.y4m -filter_complex 'hwupload_cuda,scale_npp=-1:288:interp_algo=lanczos,hwdownload' -c:v h264_nvenc -preset p7 -tune hq -y output2.mp4
fi

