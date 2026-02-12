ffmpeg -rtsp_transport tcp \
-fflags +genpts \
-i rtsp://marojahan:m200jg961@192.168.1.99:554/stream2 \
-c copy \
-an \
-f segment \
-segment_time 7 \
-segment_format mp4 \
-reset_timestamps 1 \
-strftime 1 \
/cctv/recordings/test_cam_%Y%m%d_%H%M%S.mp4
