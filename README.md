![FFmpeg on Ubuntu](https://github.com/xdrudis/video-scripts/workflows/FFmpeg%20on%20Ubuntu/badge.svg)
![FFmpeg on MacOS](https://github.com/xdrudis/video-scripts/workflows/FFmpeg%20on%20MacOS/badge.svg)
![FFmpeg on CentOS](https://github.com/xdrudis/video-scripts/workflows/FFmpeg%20on%20CentOS/badge.svg)
![FFmpeg on Alpine Linux](https://github.com/xdrudis/video-scripts/workflows/FFmpeg%20on%20Alpine%20Linux/badge.svg)

# Video scripts

* [ffmpeg-compile/](ffmpeg-compile): a script to compile FFmpeg and libraries from scratch. My goal is to have a repeatable environment in all the boxes I use.
   - Portable: MacOS/Ubuntu/CentOS/Alpine, x86-64/arm (including Raspberry Pi)
   - Includes VMAF (x86-64 only)
   - Includes Nvidia nvenc support (if driver available)
   - No root access needed. Multiple environments can coexist in different folders

Clone the repo or just do
```
curl -sL https://raw.githubusercontent.com/xdrudis/video-scripts/master/ffmpeg-compile/build-ffmpeg.sh | bash
```
