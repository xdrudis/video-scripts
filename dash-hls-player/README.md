# Adaptive Streaming Video Player

A lightweight, browser-based player for testing and development with HLS (.m3u8) and DASH (.mpd) streaming formats.

- Supports both HLS and DASH streaming formats
- Format detection based on file extension
- Adaptive bitrate streaming with quality switching
- Detailed debugging information
- Support for subtitles and captions

This player uses [HLS.js](https://github.com/video-dev/hls.js/) and [dash.js](https://github.com/Dash-Industry-Forum/dash.js/) libraries (loaded dynamically when needed).

This player is designed specifically for local testing of streaming media. You can serve and test your own manifest files directly from your laptop without needing to make it publicly available on the internet.

You can develop and debug your streaming media locally with immediate feedback.

## Quick Start

### Start the Local Server

```bash
# Start the local server
./server.js
```

The server runs on http://localhost:8000

### Bypass CORS for Development

```bash
# macOS
open -a "Google Chrome" --args --disable-web-security --user-data-dir="/tmp/chrome_dev_test"

# Windows
start chrome --disable-web-security --user-data-dir="%TEMP%\chrome_dev_test"

# Linux
google-chrome --disable-web-security --user-data-dir="/tmp/chrome_dev_test"
```

**⚠️ For development only. Don't browse regular sites with these flags.**

## Using the Player

1. Start the server and Chrome with security flags
2. Go to http://localhost:8000
3. Enter your stream URL (default: http://localhost:8000/manifest.mpd#t=60)
4. Click "Load Video"
5. Use "Show debug info" for streaming details

## Sample URLs

### HLS
- Local: http://localhost:8000/samples/hls/master.m3u8
- Public: https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8

### DASH
- Local: http://localhost:8000/samples/dash/manifest.mpd
- Public: https://dash.akamaized.net/akamai/bbb_30fps/bbb_30fps.mpd
- Public: https://dash.akamaized.net/akamai/bbb_30fps/bbb_30fps.mpd#t=60 (start at minute 1)

## Troubleshooting

- **Video Won't Play**: Check console errors, verify manifest validity
- **CORS Issues**: Ensure Chrome was launched with security flags
- **Format Detection**: Use proper file extensions (.m3u8 for HLS, .mpd for DASH)