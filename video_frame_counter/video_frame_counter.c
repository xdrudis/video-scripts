#include <libavformat/avformat.h>
#include <libavcodec/avcodec.h>
#include <libavutil/avutil.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct {
    int64_t bytes_read;
    int target_frame_count;
    int decoded_frames;
} ByteCounterContext;

// Custom IO read callback
static int read_packet_callback(void *opaque, uint8_t *buf, int buf_size) {
    void **data = (void **)opaque;
    ByteCounterContext *ctx = (ByteCounterContext *)data[0];
    FILE *file = (FILE *)data[1];

    int bytes_read = fread(buf, 1, buf_size, file);
    if (bytes_read > 0)
        ctx->bytes_read += bytes_read;

    return bytes_read > 0 ? bytes_read : AVERROR_EOF;
}

int main(int argc, char *argv[]) {
    if (argc != 3) {
        fprintf(stderr, "Usage: %s <video_file> <target_frame_count>\n", argv[0]);
        fprintf(stderr, "Frame numbers are 1-based (1 = first frame)\n");
        fprintf(stderr, "Output: bytes needed for frames 1 through target_frame_count\n");
        return 1;
    }

    const char *filename = argv[1];
    int target_frame_count = atoi(argv[2]);

    if (target_frame_count < 1) {
        fprintf(stderr, "Error: Frame count must be >= 1\n");
        return 1;
    }

    FILE *input_file = fopen(filename, "rb");
    if (!input_file) {
        fprintf(stderr, "Error: Could not open file %s\n", filename);
        return 1;
    }

    ByteCounterContext counter_ctx = {0, target_frame_count, 0};
    void *opaque[2] = {&counter_ctx, input_file};

    size_t avio_ctx_buffer_size = 4096;
    uint8_t *avio_ctx_buffer = av_malloc(avio_ctx_buffer_size);
    if (!avio_ctx_buffer) {
        fprintf(stderr, "Error: Could not allocate IO buffer\n");
        fclose(input_file);
        return 1;
    }

    AVIOContext *avio_ctx = avio_alloc_context(
        avio_ctx_buffer, avio_ctx_buffer_size,
        0, opaque, read_packet_callback, NULL, NULL
    );

    if (!avio_ctx) {
        fprintf(stderr, "Error: Could not create IO context\n");
        av_free(avio_ctx_buffer);
        fclose(input_file);
        return 1;
    }

    AVFormatContext *fmt_ctx = avformat_alloc_context();
    if (!fmt_ctx) {
        fprintf(stderr, "Error: Could not allocate format context\n");
        av_free(avio_ctx_buffer);
        avio_context_free(&avio_ctx);
        fclose(input_file);
        return 1;
    }

    fmt_ctx->pb = avio_ctx;

    if (avformat_open_input(&fmt_ctx, NULL, NULL, NULL) < 0) {
        fprintf(stderr, "Error: Could not open input\n");
        avformat_free_context(fmt_ctx);
        av_free(avio_ctx_buffer);
        avio_context_free(&avio_ctx);
        fclose(input_file);
        return 1;
    }

    if (avformat_find_stream_info(fmt_ctx, NULL) < 0) {
        fprintf(stderr, "Error: Could not find stream info\n");
        avformat_close_input(&fmt_ctx);
        av_free(avio_ctx_buffer);
        avio_context_free(&avio_ctx);
        fclose(input_file);
        return 1;
    }

    int video_stream_idx = -1;
    AVCodecContext *video_codec_ctx = NULL;
    const AVCodec *video_codec = NULL;
    int64_t *frame_bytes = NULL; 

    for (int i = 0; i < fmt_ctx->nb_streams; i++) {
        if (fmt_ctx->streams[i]->codecpar->codec_type == AVMEDIA_TYPE_VIDEO) {
            video_stream_idx = i;

            video_codec = avcodec_find_decoder(fmt_ctx->streams[i]->codecpar->codec_id);
            if (!video_codec) {
                fprintf(stderr, "Error: Could not find decoder\n");
                goto cleanup;
            }

            video_codec_ctx = avcodec_alloc_context3(video_codec);
            if (!video_codec_ctx) {
                fprintf(stderr, "Error: Could not allocate codec context\n");
                goto cleanup;
            }

            if (avcodec_parameters_to_context(video_codec_ctx, fmt_ctx->streams[i]->codecpar) < 0) {
                fprintf(stderr, "Error: Could not copy codec parameters\n");
                goto cleanup;
            }

            if (avcodec_open2(video_codec_ctx, video_codec, NULL) < 0) {
                fprintf(stderr, "Error: Could not open codec\n");
                goto cleanup;
            }

            break;
        }
    }

    if (video_stream_idx == -1) {
        fprintf(stderr, "Error: No video stream found\n");
        goto cleanup;
    }

    AVFrame *frame = av_frame_alloc();
    AVPacket *packet = av_packet_alloc();
    if (!frame || !packet) {
        fprintf(stderr, "Error: Could not allocate frame or packet\n");
        goto cleanup;
    }

    frame_bytes = calloc(target_frame_count, sizeof(int64_t));
    if (!frame_bytes) {
        fprintf(stderr, "Error: Could not allocate memory for frame bytes\n");
        goto cleanup;
    }

    int frames_decoded = 0;

    while (av_read_frame(fmt_ctx, packet) >= 0) {
        if (packet->stream_index == video_stream_idx) {
            int64_t offset_before = avio_tell(fmt_ctx->pb); // Save offset before decoding

            int ret = avcodec_send_packet(video_codec_ctx, packet);
            if (ret < 0) {
                fprintf(stderr, "Error: Could not send packet to decoder\n");
                av_packet_unref(packet);
                continue;
            }

            while (ret >= 0) {
                ret = avcodec_receive_frame(video_codec_ctx, frame);
                if (ret == AVERROR(EAGAIN) || ret == AVERROR_EOF) {
                    break;
                } else if (ret < 0) {
                    fprintf(stderr, "Error: Could not receive frame from decoder\n");
                    break;
                }

                frames_decoded++;

                if (frames_decoded <= target_frame_count) {
                    frame_bytes[frames_decoded - 1] = offset_before;
                }

                if (frames_decoded >= target_frame_count) {
                    break;
                }

                av_frame_unref(frame);
            }
        }

        av_packet_unref(packet);

        if (frames_decoded >= target_frame_count) {
            break;
        }
    }

    if (frames_decoded < target_frame_count) {
        avcodec_send_packet(video_codec_ctx, NULL);
        int ret;
        while ((ret = avcodec_receive_frame(video_codec_ctx, frame)) >= 0) {
            frames_decoded++;
            if (frames_decoded <= target_frame_count) {
                frame_bytes[frames_decoded - 1] = avio_tell(fmt_ctx->pb); // fallback
            }

            if (frames_decoded >= target_frame_count) {
                break;
            }

            av_frame_unref(frame);
        }
    }

    for (int i = 0; i < frames_decoded && i < target_frame_count; i++) {
        printf("%lld\n", (long long)frame_bytes[i]);
    }

    if (frames_decoded < target_frame_count) {
        fprintf(stderr, "Warning: Only decoded %d frames out of %d requested\n",
                frames_decoded, target_frame_count);
    }

cleanup:
    // Free allocated memory
    if (frame_bytes) free(frame_bytes);
    av_frame_free(&frame);
    av_packet_free(&packet);
    if (video_codec_ctx) avcodec_free_context(&video_codec_ctx);
    if (fmt_ctx) avformat_close_input(&fmt_ctx);
    if (avio_ctx) avio_context_free(&avio_ctx);
    if (input_file) fclose(input_file);

    return 0;
}

