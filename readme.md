Struktur Folder / File

/opt/cctv/ ← script & config
/var/log/cctv/ ← log
/mnt/cctv/ ← buffer rekaman

Berikan akses
cd /opt/cctv
chmod +x /cctv/*.sh


Ubah format CRLF Windows ke LF Linux (mengantisipasi)
sed -i 's/\r$//' *.*




