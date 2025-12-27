#!/bin/sh
set -eu

IMAGE="architectstore/certbot-hostinger"
TAG_DATE="$(date +%d%m%Y)"

docker build \
  -t "${IMAGE}:latest" \
  -t "${IMAGE}:${TAG_DATE}" \
  .
