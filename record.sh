#!/bin/bash

CONFIG_FILE="/opt/cctv/config.conf"
source "$CONFIG_FILE"

GLOBAL_LOG="/opt/cctv/record.out"
touch "$GLOBAL_LOG"


########################################
# KILL OLD FFMPEG (PER CAMERA)
########################################
for CAM in "${CAMERAS[@]}"; do
    NAME="${CAM%%|*}"
    URL="${CAM#*|}"

    echo "[INFO][$NAME] Checking old ffmpeg process..."

    PIDS=$(pgrep -f "ffmpeg.*$URL")

    if [ -n "$PIDS" ]; then
        echo "[WARN][$NAME] Killing old ffmpeg: $PIDS"
        kill -9 $PIDS
        sleep 1
    fi
done


echo -e "\n========================================"
echo "              CONFIGURATION             "
echo "========================================"

echo "LOCAL_DIR     : $LOCAL_DIR"
echo "LOG_DIR       : $LOG_DIR"
echo "SEGMENT_TIME  : $SEGMENT_TIME"
echo "USE_AUDIO     : $USE_AUDIO"
echo "TOTAL CAM     : ${#CAMERAS[@]}"

echo -e "========================================\n"

########################################
# ENSURE BASE DIRECTORIES EXIST
########################################
mkdir -p "$LOCAL_DIR"
mkdir -p "$LOG_DIR"

########################################
# AUDIO OPTIONS
########################################
if [ "$USE_AUDIO" = "yes" ]; then
    AUDIO_OPTS="-c:v copy -c:a aac -b:a 64k -ar 8000"
else
    AUDIO_OPTS="-c:v copy -an"
fi

########################################
# CREATE CAMERA DIRECTORIES
########################################
for CAM in "${CAMERAS[@]}"; do
    NAME="${CAM%%|*}"
    mkdir -p "$LOCAL_DIR/$NAME"
done

########################################
# AUTO CLEAN (PER CAMERA)
########################################
(
while true; do
    for CAM in "${CAMERAS[@]}"; do
        NAME="${CAM%%|*}"
        CAM_DIR="$LOCAL_DIR/$NAME"

        mkdir -p "$CAM_DIR"
        find "$CAM_DIR" -type f -name "*.mp4" -mmin +30 -delete
    done
    sleep 60
done
) &

########################################
# GROUP FILE OTOMATIS (PER CAMERA)
########################################
(
while true; do
    for CAM in "${CAMERAS[@]}"; do
        NAME="${CAM%%|*}"
        CAM_DIR="$LOCAL_DIR/$NAME"

        mkdir -p "$CAM_DIR"

        for file in $(find "$CAM_DIR" -maxdepth 1 -type f -name "*.mp4"); do

            filename=$(basename "$file")
            day=${filename:0:10}
            hour=${filename:11:2}

            directory="$CAM_DIR/$day/$hour"
            mkdir -p "$directory"

            if mv "$file" "$directory/"; then
                echo "[INFO][$NAME] Record baru: $directory/$filename"
            fi
        done
    done

    sleep 3
done
) &



########################################
# START RECORDING PER CAMERA
########################################
for CAM in "${CAMERAS[@]}"; do

    NAME="${CAM%%|*}"
    URL="${CAM#*|}"

    CAM_DIR="$LOCAL_DIR/$NAME"
    LOG_FILE="$LOG_DIR/${NAME}_record.log"

    mkdir -p "$CAM_DIR"
    mkdir -p "$LOG_DIR"
    touch "$LOG_FILE"

    echo "[$(date '+%Y-%m-%d %H:%M:%S')][$NAME] Starting Camera"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')][$NAME] Stream: $URL"

    ffmpeg -loglevel warning \
        -rtsp_transport tcp \
        -fflags +genpts \
        -i "$URL" \
        $AUDIO_OPTS \
        -f segment \
        -segment_time "$SEGMENT_TIME" \
        -segment_atclocktime 1 \
        -segment_format mp4 \
        -reset_timestamps 1 \
        -strftime 1 \
        "$CAM_DIR/%Y-%m-%d_%H-%M-%S.mp4" 2>&1 | \
    while read line; do
        echo "[$(date '+%Y-%m-%d %H:%M:%S')][$NAME] $line" >> "$LOG_FILE"
    done &

done


########################################
# AUTO CLEAN LOG > 24 JAM
########################################
(
while true; do
    find "$LOG_DIR" -type f -name "*_record.log" -mmin +1440 -delete
    sleep 3600
done
) &


wait



