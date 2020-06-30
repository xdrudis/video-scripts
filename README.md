![Ubuntu 18.04](https://github.com/xdrudis/video-scripts/workflows/Ubuntu%2018.04/badge.svg)
![Ubuntu 20.04](https://github.com/xdrudis/video-scripts/workflows/Ubuntu%2020.04/badge.svg)
![MacOS](https://github.com/xdrudis/video-scripts/workflows/MacOS/badge.svg)
![CentOS](https://github.com/xdrudis/video-scripts/workflows/CentOS/badge.svg)
![Alpine Linux](https://github.com/xdrudis/video-scripts/workflows/Alpine%20Linux/badge.svg)

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
