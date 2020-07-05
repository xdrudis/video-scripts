[![Ubuntu 18.04](https://github.com/xdrudis/video-scripts/workflows/Ubuntu%2018.04/badge.svg)](https://github.com/xdrudis/video-scripts/actions?query=workflow%3A%22Ubuntu+18.04%22+branch%3Amaster)
[![Ubuntu 20.04](https://github.com/xdrudis/video-scripts/workflows/Ubuntu%2020.04/badge.svg)](https://github.com/xdrudis/video-scripts/actions?query=workflow%3A%22Ubuntu+20.04%22+branch%3Amaster)
[![MacOS](https://github.com/xdrudis/video-scripts/workflows/MacOS/badge.svg)](https://github.com/xdrudis/video-scripts/actions?query=workflow%3A%22MacOS%22+branch%3Amaster)
[![CentOS](https://github.com/xdrudis/video-scripts/workflows/CentOS/badge.svg)](https://github.com/xdrudis/video-scripts/actions?query=workflow%3A%22CentOS%22+branch%3Amaster)

# Video scripts

* [ffmpeg-compile/](ffmpeg-compile): a script to compile FFmpeg and libraries from scratch. My goal is to have a repeatable environment in all the boxes I use.
   - Portable: MacOS/Ubuntu/CentOS, x86-64/arm (including Raspberry Pi)
   - Includes VMAF (x86-64 only)
   - Includes Nvidia nvenc support (if driver available)
   - No root access needed. Multiple environments can coexist in different folders

Clone the repo or just do
```
curl -sL https://raw.githubusercontent.com/xdrudis/video-scripts/master/ffmpeg-compile/build-ffmpeg.sh | bash
```
