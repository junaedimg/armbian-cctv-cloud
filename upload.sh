#!/bin/bash
source ./config.conf

mkdir -p "$LOCAL_DIR"
mkdir -p "$LOG_DIR"

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
echo ""

while true; do

    TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

    printf "[%s] %-20s\n" "$TIMESTAMP" "Scanning & Uploading..." \
        | tee -a "$LOG_DIR/upload.log"

    rclone move "$LOCAL_DIR" "$REMOTE_NAME" \
        --min-age "${MIN_AGE}s" \
        --include "*/*.mp4" \
        --transfers="$TRANSFERS" \
        --checkers="$CHECKERS" \
        --tpslimit="$TPS_LIMIT" \
        --drive-chunk-size=32M \
        --delete-empty-src-dirs \
        --log-level INFO 2>&1 \
        | tee -a "$LOG_DIR/upload.log"

    sleep 5
done
