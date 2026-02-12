#!/bin/bash
source ./config.conf

mkdir -p "$LOCAL_DIR"
mkdir -p "$LOG_DIR"

if [ "$USE_AUDIO" = "yes" ]; then
    AUDIO_OPTS="-c:v copy -c:a aac -b:a 64k -ar 8000"
else
    AUDIO_OPTS="-c:v copy -an"
fi

ffmpeg -rtsp_transport tcp \
-fflags +genpts \
-i "$RTSP_URL" \
$AUDIO_OPTS \
-f segment \
-segment_time "$SEGMENT_TIME" \
-segment_atclocktime 1 \
-segment_format mp4 \
-reset_timestamps 1 \
-strftime 1 \
"$LOCAL_DIR/%Y-%m-%d_%H-%M-%S.mp4" \
>> "$LOG_DIR/record.log" 2>&1
