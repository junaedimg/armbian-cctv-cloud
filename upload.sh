#!/bin/bash
source ./config.conf

mkdir -p "$LOCAL_DIR"
mkdir -p "$LOG_DIR"

while true; do

    # Group file ke folder hari/jam
    for file in "$LOCAL_DIR"/*.mp4; do
        [ -e "$file" ] || continue

        filename=$(basename "$file")
        day=${filename:0:10}
        hour=${filename:11:2}

        mkdir -p "$LOCAL_DIR/$day/$hour"
        mv "$file" "$LOCAL_DIR/$day/$hour/"
    done

    # # Upload
    # rclone move "$LOCAL_DIR" "$REMOTE_NAME" \
    #     --min-age 3s \
    #     --transfers=$TRANSFERS \
    #     --checkers=$CHECKERS \
    #     --tpslimit=$TPS_LIMIT \
    #     --drive-chunk-size=32M \
    #     --delete-empty-src-dirs \
    #     -v >> "$LOG_DIR/upload.log" 2>&1

    sleep 3
done
