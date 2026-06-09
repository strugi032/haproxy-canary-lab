#!/usr/bin/env bash
set -euo pipefail

if [ $# -eq 0 ]; then
    echo "Usage: $0 <percentage>"
    exit 1
fi

PERCENT=$1

if ! [[ "$PERCENT" =~ ^[0-9]+$ ]] || [ "$PERCENT" -lt 0 ] || [ "$PERCENT" -gt 100 ]; then
    echo "Error: percentage must be an integer between 0 and 100."
    exit 1
fi

CANARY_WEIGHT=$PERCENT
STABLE_TOTAL=$((100 - PERCENT))
V1A_WEIGHT=$((STABLE_TOTAL / 2))
V1B_WEIGHT=$((STABLE_TOTAL - V1A_WEIGHT))

echo "set weight application/web-v1-a $V1A_WEIGHT" | nc 127.0.0.1 9999 >/dev/null
echo "set weight application/web-v1-b $V1B_WEIGHT" | nc 127.0.0.1 9999 >/dev/null
echo "set weight application/web-v2-canary $CANARY_WEIGHT" | nc 127.0.0.1 9999 >/dev/null

./scripts/show-status.sh
