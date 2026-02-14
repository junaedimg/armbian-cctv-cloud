#!/bin/bash
source /opt/cctv/config.conf

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

########################################
# AUTO CLEAN LOG > 24 JAM
########################################
(
while true; do
    find "$LOG_DIR" -type f -name "*_upload.log" -mmin +1440 -delete
    sleep 3600
done
) &

########################################
# UPLOAD LOOP
########################################
while true; do

    for CAM in "${CAMERAS[@]}"; do

        NAME="${CAM%%|*}"
        CAM_DIR="$LOCAL_DIR/$NAME"
        REMOTE_DIR="$REMOTE_NAME/$NAME"
        LOG_FILE="$LOG_DIR/${NAME}_upload.log"

        mkdir -p "$CAM_DIR"
        mkdir -p "$LOG_DIR"
        touch "$LOG_FILE"

        MSG="[$(date '+%Y-%m-%d %H:%M:%S')][$NAME] Scanning & Uploading..."

        echo "$MSG"
        echo "$MSG" >> "$LOG_FILE"

        rclone move "$CAM_DIR" "$REMOTE_DIR" \
            --min-age "${MIN_AGE}s" \
            --include "*/*.mp4" \
            --transfers="$TRANSFERS" \
            --checkers="$CHECKERS" \
            --tpslimit="$TPS_LIMIT" \
            --drive-chunk-size=32M \
            --delete-empty-src-dirs \
            --log-level INFO 2>&1 | \
        while read line; do
            LOG_LINE="[$(date '+%Y-%m-%d %H:%M:%S')][$NAME] $line"
            echo "$LOG_LINE"
            echo "$LOG_LINE" >> "$LOG_FILE"
        done

    done

    sleep 5
done

