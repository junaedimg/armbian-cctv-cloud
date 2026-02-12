#!/bin/bash
source ./config.conf

mkdir -p "$LOCAL_DIR"
mkdir -p "$LOG_DIR"

while true; do

    rclone move "$LOCAL_DIR" "$REMOTE_NAME" \
    --min-age 3s \
    --transfers=$TRANSFERS \
    --checkers=$CHECKERS \
    --tpslimit=$TPS_LIMIT \
    --drive-chunk-size=32M \
    --delete-empty-src-dirs \
    -v >> "$LOG_DIR/upload.log" 2>&1
    sleep 3
done
