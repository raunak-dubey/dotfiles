#!/usr/bin/env sh
# Requires: rmpc, jq

set -eu

[ -z "${FILE:-}" ] && exit 0

sticker=$(rmpc sticker get "$FILE" "playCount" | jq -r '.value')
if [ -z "$sticker" ]; then
    rmpc sticker set "$FILE" "playCount" "1"
else
    rmpc sticker set "$FILE" "playCount" "$((sticker + 1))"
fi
