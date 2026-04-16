#!/bin/sh
# scripts/build-docker.sh
# Build Spark-OS sebagai Docker image

set -e

IMAGE_NAME="spark-os"
IMAGE_TAG="1.0"

# Pastikan dijalankan dari root repo
cd "$(dirname "$0")/.."

echo "Building Spark-OS Docker image..."

docker build \
  -f targets/docker/Dockerfile \
  -t "$IMAGE_NAME:$IMAGE_TAG" \
  -t "$IMAGE_NAME:latest" \
  .

echo ""
echo "Build selesai!"
echo ""
echo "Cara menjalankan:"
echo "  docker run -it $IMAGE_NAME:latest"
echo ""
echo "Atau dengan nama container:"
echo "  docker run -it --name spark-os $IMAGE_NAME:latest"
