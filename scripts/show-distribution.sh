#!/usr/bin/env bash
set -euo pipefail

REQUESTS=${1:-100}

echo "Total requests: $REQUESTS"
echo ""

for ((i=1; i<=REQUESTS; i++)); do
    curl -s -I http://localhost:8080 | awk 'tolower($1) == "x-backend-server:" {print $2}' | tr -d '\r'
done | sort | uniq -c | awk '{print $2 ":\t" $1}'
