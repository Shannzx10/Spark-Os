#!/bin/sh
# scripts/build-termux.sh
# Membuat paket distribusi Spark-OS untuk Termux (rootfs.tar.gz)
# File ini diupload ke GitHub Releases agar user tidak perlu clone repo

set -e

VERSION="1.0"
OUTPUT="spark-os-termux-${VERSION}.tar.gz"

cd "$(dirname "$0")/.."

echo "Membuat paket Termux: $OUTPUT ..."

# Kemas rootfs tanpa binary busybox (akan diganti busybox ARM saat install)
# dan tanpa direktori virtual
tar -czf "$OUTPUT" \
  --exclude="rootfs/bin/busybox" \
  --exclude="rootfs/proc" \
  --exclude="rootfs/sys" \
  --exclude="rootfs/dev" \
  --exclude="rootfs/tmp/*" \
  --exclude="rootfs/run/*" \
  --exclude="rootfs/var/log/*" \
  --exclude="rootfs/var/run/*" \
  rootfs/

echo ""
echo "Selesai: $OUTPUT"
echo "Upload file ini ke GitHub Releases."
