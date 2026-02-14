#!/bin/bash

PID_FILE="cctv.pid"

echo "================================="
echo "Cleaning old CCTV processes..."
echo "================================="

pkill -f record.sh 2>/dev/null
pkill -f upload.sh 2>/dev/null
pkill -f ffmpeg 2>/dev/null
pkill -f rclone 2>/dev/null

sleep 1

chmod +x record.sh
chmod +x upload.sh

echo "================================="
echo "Starting CCTV system..."
echo "================================="

# Jalankan satu parent background dengan nohup
nohup bash -c '
    ./record.sh >> record.out 2>&1 &
    ./upload.sh >> upload.out 2>&1 &
    wait
' >/dev/null 2>&1 &

NEW_PID=$!
echo "$NEW_PID" > "$PID_FILE"

disown "$NEW_PID"

echo "CCTV running in background (PID $NEW_PID)"
echo "Logs:"
echo "  tail -f record.out"
echo "  tail -f upload.out"
echo "================================="

# Tutup output parent agar tidak print lagi
exec >/dev/null 2>&1

exit 0
