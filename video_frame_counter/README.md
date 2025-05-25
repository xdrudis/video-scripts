# Video Frame Byte Counter

This program reads a video file and outputs the byte offsets in the file needed to decode frames 1 through *N*, where *N* is a user-specified target frame count.

When streaming video over the web, the initial startup delay depends on how many bytes of the file must be downloaded before the first frames can be decoded and displayed. This tool helps understand how fast a video can start by measuring how many bytes are required to decode the first few frames.

## Usage

```bash
./video_frame_counter <video_file> <target_frame_count>
```

- \<video_file\>: Path to the input video file.
- \<target_frame_count\>: Number of frames to decode and measure byte offsets for.

Frame numbers are 1-based, meaning frame 1 is the first frame.

## Output

The program prints the byte offset required to decode each frame from 1 up to \<target_frame_count\>. This indicates how many bytes of the video file need to be loaded to decode and display each frame in order.

## Example

```bash
./video_frame_counter data/example.mp4 10
```

Output might be:

```
123456
130000
140123
...
```

Each number corresponds to the byte position in the file where that frame could be decoded.

## Build Instructions

Make sure you have FFmpeg development libraries installed.

Compile with:

```bash
gcc -o video_frame_counter video_frame_counter.c $(pkg-config --cflags --libs libavformat libavcodec libavutil)
```

or

```bash
docker build -t video_frame_counter .
docker run --rm -v "$PWD:/data" video_frame_counter /data/input.mp4 100
```

## Notes

- The program uses FFmpeg's decoding API and a custom IO context to track bytes read from the input.
- This measurement helps evaluate how video encoding and container format affect streaming startup latency.

