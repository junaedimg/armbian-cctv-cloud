#!/bin/bash
source ./config.conf

while true; do

    rclone move "$LOCAL_DIR" "$REMOTE_NAME" \
    --min-age 3s \
    --transfers=$TRANSFERS \
    --checkers=$CHECKERS \
    --tpslimit=$TPS_LIMIT \
    --drive-chunk-size=32M \
    --delete-empty-src-dirs \
    -v >> upload.log 2>&1 | tee -a upload.log

    sleep 3
done
