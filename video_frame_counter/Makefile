
CFLAGS="-Wall"

video_frame_counter: video_frame_counter.c Makefile
	gcc $(CFLAGS) -o $@ $< $(shell pkg-config --cflags --libs libavformat libavcodec libavutil)

docker: video_frame_counter.c
	docker build -t video_frame_counter .

clean:
	rm -f video_frame_counter
