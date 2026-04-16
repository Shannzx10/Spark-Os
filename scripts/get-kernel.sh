#!/bin/sh
# scripts/get-kernel.sh
# Download kernel (vmlinuz) dari Alpine Linux mini ISO
# Alpine dipilih karena kernelnya kecil dan stabil, cocok untuk OS minimal

set -e

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
BOOT_DIR="$REPO_DIR/targets/iso/boot"
TMP_ISO="/tmp/alpine-temp.iso"
ALPINE_VERSION="3.21"
ALPINE_FULL_VERSION="3.21.6"
ALPINE_ARCH="x86_64"
ALPINE_URL="https://dl-cdn.alpinelinux.org/alpine/v${ALPINE_VERSION}/releases/${ALPINE_ARCH}/alpine-virt-${ALPINE_FULL_VERSION}-${ALPINE_ARCH}.iso"

echo "======================================"
echo "  Spark-OS: Download Kernel"
echo "======================================"
echo ""

# Cek dependensi
for cmd in wget xorriso; do
  if ! command -v "$cmd" > /dev/null 2>&1; then
    echo "ERROR: '$cmd' tidak ditemukan."
    echo "Install dengan: apt install wget xorriso"
    exit 1
  fi
done

# Jika vmlinuz sudah ada, tanya user
if [ -f "$BOOT_DIR/vmlinuz" ]; then
  echo "vmlinuz sudah ada di targets/iso/boot/vmlinuz"
  printf "Download ulang? [y/N] "
  read answer
  case "$answer" in
    y|Y) ;;
    *) echo "Dibatalkan."; exit 0 ;;
  esac
fi

mkdir -p "$BOOT_DIR"

# Download Alpine ISO
echo "Mendownload Alpine Linux ${ALPINE_FULL_VERSION} virt (~45MB)..."
echo "URL: $ALPINE_URL"
echo ""
wget -q --show-progress -O "$TMP_ISO" "$ALPINE_URL"

# Extract vmlinuz dari ISO menggunakan xorriso
echo ""
echo "Mengekstrak kernel dari ISO..."
xorriso -osirrox on \
  -indev "$TMP_ISO" \
  -extract boot/vmlinuz-virt "$BOOT_DIR/vmlinuz" \
  2>/dev/null

# Verifikasi hasil
if [ ! -f "$BOOT_DIR/vmlinuz" ]; then
  echo "ERROR: Gagal mengekstrak kernel."
  rm -f "$TMP_ISO"
  exit 1
fi

# Hapus ISO sementara
rm -f "$TMP_ISO"

echo "Kernel berhasil disimpan: targets/iso/boot/vmlinuz"
echo "Ukuran: $(du -sh "$BOOT_DIR/vmlinuz" | cut -f1)"
echo ""
echo "Langkah selanjutnya:"
echo "  sh scripts/build-initrd.sh"
echo "  sh scripts/build-iso.sh"
