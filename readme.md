# Edge CCTV Cloud Archiver

Sistem perekaman CCTV berbasis Edge menggunakan RTSP + FFmpeg + rclone.

Project ini berjalan pada perangkat edge (misalnya STB Armbian) untuk:

- Mengambil stream RTSP dari IP Camera
- Membagi rekaman setiap N detik (segment)
- Menyimpan sementara di buffer lokal
- Mengunggah otomatis ke Google Drive
- Menghapus file lokal setelah upload berhasil

---

## 🧠 Arsitektur Sistem
IP Camera (RTSP)<br>
↓  
FFmpeg (Segment Recording)<br>
↓  
Buffer Lokal (/mnt/cctv)<br>
↓  
Uploader (rclone)<br>
↓  
Google Drive (Cloud Archive)

---

## 📁 Struktur Folder
``` bash
/
├── opt/
│ └── cctv/
│ ├── config.conf # File konfigurasi utama
│ ├── record.sh # Script perekaman RTSP (FFmpeg)
│ ├── upload.sh # Script upload ke Google Drive (rclone)
│ ├── run.sh # Menjalankan recorder + uploader
│ └── test.sh # Script pengujian manual
│
├── var/
│ └── log/
│ └── cctv/
│ ├── record.log # Log perekaman
│ └── upload.log # Log upload
│
└── mnt/
└── cctv/
├── 2026-02-12_10-00-00.mp4
├── 2026-02-12_10-00-30.mp4
└── ...
```