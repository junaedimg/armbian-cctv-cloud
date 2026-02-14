#!/bin/bash

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

# Jalankan keduanya di background
./record.sh >> record.out 2>&1 &
./upload.sh >> upload.out 2>&1 &

# Simpan PID kalau mau
echo $! > cctv.pid

echo "CCTV system started"

# WAJIB: tunggu proses tetap hidup
wait
