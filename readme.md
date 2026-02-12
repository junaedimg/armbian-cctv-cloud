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
Buffer Lokal (/cctv)<br>
↓  
Uploader (rclone)<br>
↓  
Google Drive (Cloud Archive)

---

## 📁 Struktur Folder Local STB
``` bash
/
├── opt/
│   └── cctv/
│       ├── config.conf      # File konfigurasi utama
│       ├── record.sh        # Script perekaman RTSP (FFmpeg)
│       ├── upload.sh        # Script upload ke Google Drive (rclone)
│       ├── run.sh           # Menjalankan recorder + uploader
│       └── test.sh          # Script pengujian manual
│
├── var/
│   └── log/
│       └── cctv.log         # Log sistem (record + upload)
│
└── cctv/
    ├── 2026-02-12/
    │   ├── 09/
    │   │   ├── 2026-02-12_09-00-00.mp4
    │   │   ├── 2026-02-12_09-00-30.mp4
    │   │   └── ...
    │   │
    │   └── 10/
    │       ├── 2026-02-12_10-00-00.mp4
    │       ├── 2026-02-12_10-00-30.mp4
    │       ├── ...
    │       └── ...
    │
    └── 2026-02-13/
        ├── 00/
        ├── 01/
        └── ...
```

## 📁 Struktur Folder Cloud (Google Drive)
Secara struktur sama seperti dilocal, metode nya upload ke cloude -> delete local.
``` bash
Google Drive
└── CCTV/
    └── YYYY-MM-DD/
        └── HH/
            └── YYYY-MM-DD_HH-MM-SS.mp4
```

## 🚀 Langkah Instalasi

### 1️⃣ Install Dependency

```bash
apt update
apt install ffmpeg rclone -y
```

---

### 2️⃣ Konfigurasi rclone

```bash
rclone config
```

---

### 3️⃣ Copy Project

```bash
/opt/cctv
```

---

### 4️⃣ Ubah Format CRLF (File dari Windows)

```bash
cd /opt/cctv
sed -i 's/\r$//' *.*
```

---

### 5️⃣ Test Record & Upload (File untuk test di awal saja)

```bash

```

---

### 6️⃣ Jalankan Sistem

```bash
./run.sh
```

---

## ✅ Selesai

Sistem siap digunakan sebagai **Edge CCTV Cloud Archiver**.
