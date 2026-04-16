#!/bin/sh
# scripts/build-iso.sh
# Build Spark-OS sebagai file ISO bootable
#
# Dependensi (install dulu):
#   Ubuntu/Debian : apt install grub-pc-bin grub-efi-amd64-bin xorriso mtools
#   Arch Linux    : pacman -S grub xorriso mtools
#
# Kernel (vmlinuz) dan initrd harus sudah ada di:
#   targets/iso/boot/vmlinuz
#   targets/iso/boot/initrd.img
#
# Cara mendapatkan kernel:
#   - Ambil dari distro lain (misal: extract dari Alpine Linux ISO)
#   - Atau build sendiri dari kernel.org

set -e

VERSION="1.0"
OUTPUT="spark-os-${VERSION}.iso"
WORK_DIR="/tmp/spark-iso-build"
REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"

echo "======================================"
echo "  Spark-OS ISO Builder"
echo "======================================"
echo ""

# Cek dependensi
for cmd in grub-mkrescue xorriso mformat; do
  if ! command -v "$cmd" > /dev/null 2>&1; then
    echo "ERROR: '$cmd' tidak ditemukan."
    echo "Install dengan: apt install grub-pc-bin grub-efi-amd64-bin xorriso mtools"
    exit 1
  fi
done

# Cek kernel dan initrd
if [ ! -f "$REPO_DIR/targets/iso/boot/vmlinuz" ]; then
  echo "ERROR: Kernel tidak ditemukan di targets/iso/boot/vmlinuz"
  echo ""
  echo "Jalankan dulu: sh scripts/get-kernel.sh"
  exit 1
fi

if [ ! -f "$REPO_DIR/targets/iso/boot/initrd.img" ]; then
  echo "ERROR: initrd tidak ditemukan di targets/iso/boot/initrd.img"
  echo "Jalankan dulu: sh scripts/build-initrd.sh"
  exit 1
fi

# Siapkan working directory
echo "[1/4] Menyiapkan struktur ISO..."
rm -rf "$WORK_DIR"
mkdir -p "$WORK_DIR/boot/grub"
mkdir -p "$WORK_DIR/rootfs"

# Copy kernel dan initrd
cp "$REPO_DIR/targets/iso/boot/vmlinuz"  "$WORK_DIR/boot/"
cp "$REPO_DIR/targets/iso/boot/initrd.img" "$WORK_DIR/boot/"

# Copy grub config
cp "$REPO_DIR/targets/iso/grub.cfg" "$WORK_DIR/boot/grub/"

# Copy rootfs
echo "[2/4] Menyalin rootfs..."
cp -r "$REPO_DIR/rootfs" "$WORK_DIR/"

# Build ISO dengan GRUB
echo "[3/4] Membangun ISO dengan GRUB..."
grub-mkrescue \
  --output="$REPO_DIR/$OUTPUT" \
  "$WORK_DIR" \
  -- -volid "SPARK-OS"

# Cleanup
echo "[4/4] Membersihkan temporary files..."
rm -rf "$WORK_DIR"

echo ""
echo "======================================"
echo "  Build selesai!"
echo "======================================"
echo ""
echo "File ISO: $REPO_DIR/$OUTPUT"
echo ""
echo "Cara menjalankan di QEMU:"
echo "  qemu-system-x86_64 -cdrom $OUTPUT -m 256M"
echo ""
echo "Cara menjalankan di VirtualBox:"
echo "  Buat VM baru -> pilih ISO ini sebagai boot disk"
