#!/bin/sh
set -eu

IMAGE="architectstore/certbot-hostinger"
TAG_DATE="$(date +%d%m%Y)"

docker buildx create --name multiarch --driver docker-container --use
docker buildx inspect --bootstrap

docker buildx build --platform linux/amd64,linux/arm64 \
  -t "${IMAGE}:latest" \
  -t "${IMAGE}:${TAG_DATE}" \
  --push .