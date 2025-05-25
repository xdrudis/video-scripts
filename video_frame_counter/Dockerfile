FROM alpine:latest

# Install build tools and FFmpeg dev libraries
RUN apk add --no-cache \
    build-base \
    ffmpeg-dev \
    pkgconfig

# Create working directory
WORKDIR /app

# Copy source code
COPY video_frame_counter.c .

# Compile the program
RUN gcc -o video_frame_counter video_frame_counter.c \
    `pkg-config --cflags --libs libavformat libavcodec libavutil` \
    -Wall -O2

ENTRYPOINT ["/app/video_frame_counter"]
