#!/bin/bash
# Static arm64 build for the Skyworth TV (32-bit Android userspace, arm64 kernel).
# Output goes straight into the TvOP proxy app: ~/Code/skyworth-tv/tvop-proxy/core/libsingbox.so
set -euo pipefail
cd "$(dirname "$0")"
OUT=${1:-$HOME/Code/skyworth-tv/tvop-proxy/core/libsingbox.so}
mkdir -p "$(dirname "$OUT")"
CGO_ENABLED=0 GOOS=linux GOARCH=arm64 go build -trimpath \
    -tags "tv,with_gvisor,with_utls,with_clash_api" \
    -ldflags "-s -w -buildid= -X github.com/sagernet/sing-box/constant.Version=$(git describe --tags --always)-tv" \
    -o "$OUT" ./cmd/sing-box
ls -l "$OUT"
