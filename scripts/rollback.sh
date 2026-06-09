#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

echo "Rolling back to stable (canary: 0)..."

"$SCRIPT_DIR/set-canary.sh" 0
