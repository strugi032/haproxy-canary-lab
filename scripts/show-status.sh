#!/usr/bin/env bash
set -euo pipefail

echo "show stat" | nc 127.0.0.1 9999 | awk -F',' '
    BEGIN { printf "%-15s %-10s %-10s\n", "SERVER", "STATUS", "WEIGHT" }
    $1 == "application" && $2 != "BACKEND" && $2 != "FRONTEND" {
        printf "%-15s %-10s %-10s\n", $2, $18, $19
    }
'
