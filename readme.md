# CCTV Cloud Archiver
Sistem perekaman CCTV berbasis Edge menggunakan RTSP + FFmpeg + rclone, dengan dukungan multi camera.

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
Struktur lokal disamakan dengan Google Drive (berdasarkan tanggal dan jam).

```bash
/
├── opt/
│   └── cctv/
│       ├── config.conf        # File konfigurasi utama
│       ├── record.sh          # Script perekaman RTSP (FFmpeg)
│       ├── upload.sh          # Script upload ke Google Drive (rclone)
│       ├── run.sh             # Entry point untuk mulai manual
│       ├── run_auto.sh        # Entry point untuk systemd (auto start)
│       ├── record.out         # Output mentah FFmpeg (debug)
│       ├── upload.out         # Output mentah rclone (debug)
│       └── cctv.service       # File service systemd
│
├── var/
│   └── log/
│       └── cctv/
│           ├── cam1_record.log
│           ├── cam1_upload.log
│           ├── cam2_record.log
│           └── cam2_upload.log
│
└── cctv/
    └── recordings/
        ├── cam1/
        │   └── YYYY-MM-DD/
        │       └── HH/
        │           └── YYYY-MM-DD_HH-MM-SS.mp4
        │
        ├── cam2/
        │   └── YYYY-MM-DD/
        │       └── HH/
        │           └── YYYY-MM-DD_HH-MM-SS.mp4
        │
        └── cam3/
            └── YYYY-MM-DD/
                └── HH/
                    └── YYYY-MM-DD_HH-MM-SS.mp4
```

## 📁 Struktur Folder Cloud (Google Drive)
Secara struktur sama seperti dilocal, metode nya upload ke cloude -> delete local.
``` bash
Google Drive
└── CCTV/
    ├── cam1/
    │   └── YYYY-MM-DD/
    │       └── HH/
    │           └── YYYY-MM-DD_HH-MM-SS.mp4
    │
    ├── cam2/
    │   └── YYYY-MM-DD/
    │       └── HH/
    │           └── YYYY-MM-DD_HH-MM-SS.mp4
    │
    └── cam3/
        └── YYYY-MM-DD/
            └── HH/
                └── YYYY-MM-DD_HH-MM-SS.mp4

```

## 🚀 Langkah Instalasi

### 1 Install Dependency
```bash
apt update
apt install ffmpeg rclone -y
```

### 2 Konfigurasi rclone
```bash
rclone config
```

### 3 Copy / Download Project ini ke PATH
```bash
/opt/cctv
```

### 4 Ubah Format CRLF (File dari Windows)
```bash
cd /opt/cctv
find . -type f \( -name "*.sh" -o -name "*.conf" -o -name "*.service" \) -exec sed -i 's/\r$//' {} +
```

### 5 Copy service
```bash
sudo cp /opt/cctv/cctv.service /etc/systemd/system/
```

### 6 Run service (auto run boot)
```bash
sudo systemctl daemon-reload
systemctl enable cctv
systemctl start cctv
sudo systemctl restart cctv
```

## ✅ Selesai
Sistem siap digunakan.

---

## 🛠️ Perintah Penting / Catatan (Maintenance & Monitoring)

```bash
# Restart Service
systemctl restart cctv

# Restart Service
systemctl stop cctv

# Perbaikan CRLF (jika file dari Windows) jalankan pertama kali sebelum run.sh
cd /opt/cctv
sed -i 's/\r$//' *.sh

# Permission (pertama kali)
chmod +x run.sh
chmod +x stop.sh

# Menjalankan sistem saat manual
./run.sh

# Menghentikan sistem saat manual
./stop.sh

# Cek status proses
ps aux | grep ffmpeg
ps aux | grep rclone

chmod +x /opt/cctv/run_auto.sh

# Cek Output
tail -f /var/log/cctv/record.log
tail -f /var/log/cctv/upload.log
```