#!/bin/bash
source ./config.conf

mkdir -p "$LOCAL_DIR"
mkdir -p "$LOG_DIR"

# ==========================
# AUTO CLEAN FILE > 30 MENIT
# ==========================
(
while true; do
    find "$LOCAL_DIR" -type f -name "*.mp4" -mmin +30 -print -delete >> "$LOG_DIR/record.log" 2>&1
    sleep 60
done
) &

# ==========================
# MONITOR FILE BARU (CLI INFO)
# ==========================
(
LAST_FILE=""
while true; do
    NEW_FILE=$(ls -t "$LOCAL_DIR"/*.mp4 2>/dev/null | head -n 1)

    if [ -n "$NEW_FILE" ] && [ "$NEW_FILE" != "$LAST_FILE" ]; then
        echo "[INFO] File selesai dibuat: $(basename "$NEW_FILE")"
        LAST_FILE="$NEW_FILE"
    fi

    sleep 2
done
) &

# ==========================
# Record Audio
# ==========================
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
