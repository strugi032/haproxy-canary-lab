#!/usr/bin/env bash
set -euo pipefail

echo "set weight application/web-v1-a 50" | nc 127.0.0.1 9999 >/dev/null
echo "set weight application/web-v1-b 50" | nc 127.0.0.1 9999 >/dev/null
echo "set weight application/web-v2-canary 0" | nc 127.0.0.1 9999 >/dev/null

./scripts/show-status.sh
