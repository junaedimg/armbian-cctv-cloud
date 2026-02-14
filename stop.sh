#!/bin/bash

PID_FILE="cctv.pid"

echo "================================="
echo "Stopping CCTV Service..."
echo "================================="

# ==========================
# Kill berdasarkan PID file
# ==========================
if [ -f "$PID_FILE" ]; then
    PID=$(cat "$PID_FILE")

    if ps -p "$PID" > /dev/null 2>&1; then
        echo "Killing process group (PID $PID)..."
        kill -TERM -"$PID" 2>/dev/null
        sleep 2
        kill -KILL -"$PID" 2>/dev/null
        echo "Process group stopped."
    else
        echo "PID file found but process not running."
    fi

    rm -f "$PID_FILE"
else
    echo "PID file not found."
fi

# ==========================
# Fallback Clean Kill
# ==========================
echo "Cleaning remaining processes..."

pkill -9 -f record.sh 2>/dev/null
pkill -9 -f upload.sh 2>/dev/null
pkill -9 -f ffmpeg 2>/dev/null
pkill -9 -f rclone 2>/dev/null

sleep 1

# ==========================
# Verifikasi
# ==========================
REMAINING=$(ps aux | grep -E "record.sh|upload.sh|ffmpeg|rclone" | grep -v grep)

if [ -z "$REMAINING" ]; then
    echo "All CCTV processes successfully stopped."
else
    echo "Warning: Some processes may still be running:"
    echo "$REMAINING"
fi

echo "================================="
