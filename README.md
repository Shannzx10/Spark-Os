```
  ____                   _      ___  ____  
 / ___| _ __   __ _ _ __| | __ / _ \/ ___| 
 \___ \| '_ \ / _` | '__| |/ /| | | \___ \ 
  ___) | |_) | (_| | |  |   < | |_| |___) |
 |____/| .__/ \__,_|_|  |_|\_\ \___/|____/ 
       |_|                                 
```

# Spark OS v1.0

Spark OS adalah sistem operasi Linux minimal berbasis BusyBox. Ringan, cepat, dan bisa dijalankan di berbagai environment — dari Android, VPS/container, hingga mesin virtual.

## Environment yang Didukung

| Environment | Platform | Status |
|-------------|----------|--------|
| ISO Bootable (VM / Bare Metal) | x86_64 | ✅ Siap |
| Termux (Android) | aarch64 | ✅ Siap |
| Docker / VPS / Chroot | Linux x86_64 | ✅ Siap |

---

## Download

| File | Keterangan |
|------|-----------|
| [spark-os-1.0.iso](https://github.com/Shannzx10/Spark-Os/releases/download/v1.0/spark-os-1.0.iso) | ISO bootable untuk VM / PC |

---

## Cara Menjalankan

### ISO Bootable — QEMU

```sh
qemu-system-x86_64 -cdrom spark-os-1.0.iso -m 512M -net nic -net user
```

### ISO Bootable — VirtualBox

1. Buat VM baru (Type: Linux, Version: Other Linux 64-bit)
2. RAM minimal 256MB
3. Storage → Optical Drive → pilih `spark-os-1.0.iso`
4. Start

### Termux (Android)

**Requirement:** Aplikasi [Termux](https://termux.dev) dari F-Droid

```sh
pkg install git -y
git clone https://github.com/Shannzx10/Spark-Os.git
cd Spark-Os
sh targets/termux/install.sh

# Jalankan
spark-os
```

### Docker / VPS / Chroot

```sh
git clone https://github.com/Shannzx10/Spark-Os.git
cd Spark-Os
sh scripts/build-docker.sh
docker run -it spark-os:latest
```

---

## Package Manager — SPT

Spark OS dilengkapi dengan **spt** (Spark Package Tools), package manager minimalis yang dirancang khusus untuk Spark OS.

### Perintah Dasar

```sh
spt update              # Perbarui daftar package
spt install <nama>      # Install package
spt remove <nama>       # Hapus package
spt list                # Tampilkan package yang tersedia
spt search <kata>       # Cari package
spt info <nama>         # Info detail package
```

### Contoh

```sh
spt update
spt install nano
spt install bash jq curl
```

### Package yang Tersedia

| Package | Keterangan |
|---------|-----------|
| `bash` | GNU Bash shell |
| `nano` | Text editor terminal |
| `curl` | HTTP/HTTPS client |
| `jq` | JSON processor |
| `btm` | System monitor (alternatif htop) |

> Repository package dikelola secara terpisah di [Spark-Package-Tools](https://github.com/Shannzx10/Spark-Package-Tools).

---

## Build dari Source

```sh
# Install dependensi (Ubuntu/Debian)
apt install wget xorriso grub-pc-bin grub-efi-amd64-bin mtools

# Clone repo
git clone https://github.com/Shannzx10/Spark-Os.git
cd Spark-Os

# 1. Download kernel dari Alpine Linux (~60MB, sekali saja)
sh scripts/get-kernel.sh

# 2. Build initrd dari rootfs
sh scripts/build-initrd.sh

# 3. Build ISO
sh scripts/build-iso.sh

# Jalankan
qemu-system-x86_64 -cdrom spark-os-1.0.iso -m 512M -net nic -net user
```

---

## Struktur Repo

```
Spark-Os/
├── rootfs/                  # Filesystem utama OS
│   ├── bin/                 # Perintah (busybox + spt)
│   ├── etc/                 # Konfigurasi sistem
│   └── lib/modules/         # Kernel modules (NIC, packet socket)
├── targets/
│   ├── docker/              # Dockerfile
│   ├── termux/              # Installer Android
│   └── iso/                 # GRUB config
└── scripts/
    ├── get-kernel.sh        # Download kernel Alpine Linux
    ├── build-initrd.sh      # Build initrd dari rootfs
    ├── build-iso.sh         # Build ISO bootable
    ├── build-docker.sh      # Build Docker image
    └── build-termux.sh      # Package untuk Termux
```

---

## Spesifikasi

| Komponen | Detail |
|----------|--------|
| Base | BusyBox (400+ perintah dalam 1 binary) |
| Shell | ash (POSIX compatible) |
| Init | BusyBox init + inittab |
| Kernel | Linux 6.12 (Alpine virt) |
| Timezone | WIB (UTC+7) |
| Ukuran ISO | ~47MB |

---

## Lisensi

MIT License
