#!/bin/bash
source ./config.conf

echo "========== CONFIG =========="

while IFS='=' read -r key value; do
    # skip comment dan baris kosong
    [[ "$key" =~ ^#.*$ || -z "$key" ]] && continue
    eval echo "$key = \$$key"
done < config.conf

echo "============================"

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
# GROUP FILE OTOMATIS
# ==========================
(
while true; do
    for file in "$LOCAL_DIR"/*.mp4; do
        [ -e "$file" ] || continue

        filename=$(basename "$file")
        day=${filename:0:10}
        hour=${filename:11:2}

        directory="$LOCAL_DIR/$day/$hour"

        mkdir -p "$directory"

        if mv "$file" "$directory/" 2>/dev/null; then
            echo "[INFO] Record baru: $directory/$filename"
        fi
    done

    sleep 3
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
