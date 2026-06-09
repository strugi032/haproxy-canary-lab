#!/usr/bin/env bash
set -euo pipefail

REQUESTS=${1:-100}

if ! [[ "$REQUESTS" =~ ^[1-9][0-9]*$ ]]; then
    echo "Error: request count must be a positive integer."
    exit 1
fi

TMP_FILE=$(mktemp)
trap 'rm -f "$TMP_FILE"' EXIT

echo "Total requests: $REQUESTS"
echo ""

if ! curl -s -I http://127.0.0.1:8080 > /dev/null; then
    echo "Error: HAProxy is unavailable at http://127.0.0.1:8080"
    exit 1
fi

if ! curl -s -I http://127.0.0.1:8080 | grep -qi "x-backend-server:"; then
    echo "Error: X-Backend-Server header is missing from the response."
    exit 1
fi

for ((i=1; i<=REQUESTS; i++)); do
    curl -s -I http://127.0.0.1:8080 | awk 'tolower($1) == "x-backend-server:" {print $2}' | tr -d '\r' >> "$TMP_FILE"
done

v1a=$(grep -c "web-v1-a" "$TMP_FILE" || true)
v1b=$(grep -c "web-v1-b" "$TMP_FILE" || true)
v2canary=$(grep -c "web-v2-canary" "$TMP_FILE" || true)

printf "%-15s %s\n" "web-v1-a:" "$v1a"
printf "%-15s %s\n" "web-v1-b:" "$v1b"
printf "%-15s %s\n" "web-v2-canary:" "$v2canary"
