#!/bin/bash

CONFIG_FILE="/opt/cctv/config.conf"
source "$CONFIG_FILE"

########################################
# SANITIZE (ANTI CRLF)
########################################
sanitize() {
    echo "$1" | tr -d '\r'
}

LOCAL_DIR=$(sanitize "$LOCAL_DIR")
REMOTE_NAME=$(sanitize "$REMOTE_NAME")
TRANSFERS=$(sanitize "$TRANSFERS")
CHECKERS=$(sanitize "$CHECKERS")
TPS_LIMIT=$(sanitize "$TPS_LIMIT")
SEGMENT_TIME=$(sanitize "$SEGMENT_TIME")
MIN_AGE_BUFFER=$(sanitize "$MIN_AGE_BUFFER")

for i in "${!CAMERAS[@]}"; do
    CAMERAS[$i]=$(sanitize "${CAMERAS[$i]}")
done

########################################
# SETUP
########################################
mkdir -p "$LOCAL_DIR"

MIN_AGE=$((SEGMENT_TIME + MIN_AGE_BUFFER))

clear

echo -e "\n=================================================="
echo "                CCTV UPLOAD SERVICE              "
echo "=================================================="
printf "  %-18s : %s s\n" "Segment Time" "$SEGMENT_TIME"
printf "  %-18s : %s s\n" "Upload Min Age" "$MIN_AGE"
printf "  %-18s : %s\n" "Local Directory" "$LOCAL_DIR"
printf "  %-18s : %s\n" "Remote" "$REMOTE_NAME"
printf "  %-18s : %s\n" "Transfers" "$TRANSFERS"
printf "  %-18s : %s\n" "Checkers" "$CHECKERS"
printf "  %-18s : %s\n" "TPS Limit" "$TPS_LIMIT"
echo -e "==================================================\n"

########################################
# UPLOAD LOOP
########################################
while true; do

    for CAM in "${CAMERAS[@]}"; do

        NAME="${CAM%%|*}"
        CAM_DIR="$LOCAL_DIR/$NAME"
        REMOTE_DIR="$REMOTE_NAME/$NAME"

        mkdir -p "$CAM_DIR"

        echo "[$(date '+%Y-%m-%d %H:%M:%S')][$NAME] Scanning & Uploading..."

        rclone move "$CAM_DIR" "$REMOTE_DIR" \
            --min-age "${MIN_AGE}s" \
            --include "**/*.mp4" \
            --transfers=1 \
            --checkers=1 \
            --tpslimit=1 \
            --tpslimit-burst=1 \
            --drive-chunk-size=32M \
            --delete-empty-src-dirs \
            --timeout 1m \
            --contimeout 30s \
            --low-level-retries=10 \
            --retries=5 \
            --log-level INFO

        # 🔥 delay antar kamera (anti throttle)
        sleep 5

    done

    sleep 10
done