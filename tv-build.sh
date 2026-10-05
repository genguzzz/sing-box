#!/bin/bash
# Static arm64 build for the Skyworth TV (32-bit Android userspace, arm64 kernel).
# Output goes straight into the TvOP proxy app (github.com/genguzzz/tvop): <tvop>/proxy/core/libsingbox.so,
# where <tvop> is the workspace this repo is a submodule of (external/sing-box), else ~/Code/tvop.
set -euo pipefail
cd "$(dirname "$0")"
TVOP=$(cd ../.. && pwd)   # already in the repo directory
[ -f "$TVOP/proxy/build.sh" ] || TVOP=$HOME/Code/tvop
OUT=${1:-$TVOP/proxy/core/libsingbox.so}
mkdir -p "$(dirname "$OUT")"
CGO_ENABLED=0 GOOS=linux GOARCH=arm64 go build -trimpath \
    -tags "tv,with_gvisor,with_utls,with_clash_api" \
    -ldflags "-s -w -buildid= -X github.com/sagernet/sing-box/constant.Version=$(git describe --tags --always)-tv" \
    -o "$OUT" ./cmd/sing-box
ls -l "$OUT"
