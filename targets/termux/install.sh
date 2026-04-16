#!/bin/sh
# ─────────────────────────────────────────────────────────
#  Spark-OS Installer for Termux (Android)
#  Usage: sh targets/termux/install.sh
# ─────────────────────────────────────────────────────────

set -e

SPARK_DIR="$HOME/spark-os"
REPO_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
LAUNCHER="$PREFIX/bin/spark-os"

# ── Check Termux ──────────────────────────────────────────
if [ -z "$TERMUX_VERSION" ] && [ ! -d "/data/data/com.termux" ]; then
  echo "E: This script is for Termux only."
  exit 1
fi

echo ""
echo "  Spark-OS Installer for Termux"
echo "  ────────────────────────────"
echo ""

# ── 1. Dependencies ───────────────────────────────────────
printf "[1/5] Installing dependencies..."
pkg install -y -q proot wget 2>/dev/null
echo " Done"

# ── 2. Copy rootfs ────────────────────────────────────────
printf "[2/5] Setting up rootfs..."
rm -rf "$SPARK_DIR"
cp -r "$REPO_DIR/rootfs" "$SPARK_DIR"
echo " Done"

# ── 3. Install ARM64 BusyBox + musl libc ─────────────────
printf "[3/5] Installing ARM64 BusyBox..."
TERMUX_TARGET="$(cd "$(dirname "$0")" && pwd)"
cp "$TERMUX_TARGET/busybox" "$SPARK_DIR/bin/busybox"
chmod +x "$SPARK_DIR/bin/busybox"
mkdir -p "$SPARK_DIR/lib" "$SPARK_DIR/usr/bin"
cp "$TERMUX_TARGET/lib/ld-musl-aarch64.so.1" "$SPARK_DIR/lib/"
ln -sf ld-musl-aarch64.so.1 "$SPARK_DIR/lib/libc.musl-aarch64.so.1"
cp "$TERMUX_TARGET/curl" "$SPARK_DIR/usr/bin/curl"
chmod +x "$SPARK_DIR/usr/bin/curl"
# Copy CA certificates dari Termux supaya curl bisa verifikasi HTTPS
mkdir -p "$SPARK_DIR/etc/ssl/certs"
CERT_SRC=""
for f in "$PREFIX/etc/tls/cert.pem" "$PREFIX/share/ca-certificates/ca-bundle.crt" "/etc/ssl/certs/ca-certificates.crt"; do
  [ -f "$f" ] && CERT_SRC="$f" && break
done
[ -n "$CERT_SRC" ] && cp "$CERT_SRC" "$SPARK_DIR/etc/ssl/certs/ca-certificates.crt"
echo " Done"

# ── 4. Rebuild BusyBox symlinks ───────────────────────────
printf "[4/5] Rebuilding BusyBox symlinks..."
PROOT_BASE="proot --link2symlink -0 -r $SPARK_DIR -w /"
$PROOT_BASE /bin/busybox --install -s /bin      2>/dev/null || true
$PROOT_BASE /bin/busybox --install -s /sbin     2>/dev/null || true
$PROOT_BASE /bin/busybox --install -s /usr/bin  2>/dev/null || true
$PROOT_BASE /bin/busybox --install -s /usr/sbin 2>/dev/null || true
echo " Done"

# ── 5. Create launcher ────────────────────────────────────
printf "[5/5] Creating launcher..."
cat > "$LAUNCHER" << LAUNCHER_EOF
#!/bin/sh
unset LD_PRELOAD
exec proot \\
  --link2symlink \\
  --kill-on-exit \\
  -0 \\
  -r "$SPARK_DIR" \\
  --bind=/dev:/dev \\
  --bind=/proc:/proc \\
  --bind=/sys:/sys \\
  -w /root \\
  /bin/sh -l
LAUNCHER_EOF
chmod +x "$LAUNCHER"
echo " Done"

echo ""
echo "  Installation complete!"
echo "  ──────────────────────"
echo "  Run Spark-OS with: spark-os"
echo ""
