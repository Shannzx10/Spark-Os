#!/bin/sh
# scripts/build-initrd.sh
# Membuat initrd (initial RAM disk) dari rootfs Spark-OS
# initrd ini yang dimuat kernel saat boot sebelum mount filesystem utama

set -e

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
OUTPUT="$REPO_DIR/targets/iso/boot/initrd.img"
WORK_DIR="/tmp/spark-initrd"

echo "Membangun initrd.img ..."

# Siapkan working directory
rm -rf "$WORK_DIR"
cp -r "$REPO_DIR/rootfs" "$WORK_DIR"

# Hapus file yang tidak perlu di dalam initrd
rm -rf "$WORK_DIR/proc" "$WORK_DIR/sys" "$WORK_DIR/dev"
mkdir -p "$WORK_DIR/proc" "$WORK_DIR/sys" "$WORK_DIR/dev"

# Buat initrd sebagai cpio archive yang dikompres dengan gzip
mkdir -p "$(dirname "$OUTPUT")"

cd "$WORK_DIR"
find . | cpio -H newc -o | gzip -9 > "$OUTPUT"

# Cleanup
rm -rf "$WORK_DIR"

echo "Selesai: $OUTPUT"
echo "Ukuran: $(du -sh "$OUTPUT" | cut -f1)"
