#!/usr/bin/env bash
# scripts/healthcheck.sh - simple service health check examples
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <url>"
  exit 2
fi

URL=$1

if command -v curl >/dev/null 2>&1; then
  status=$(curl -s -o /dev/null -w "%{http_code}" "$URL" || true)
  if [[ "$status" =~ ^2 ]]; then
    echo "HEALTHY: $URL returned $status"
    exit 0
  else
    echo "UNHEALTHY: $URL returned $status"
    exit 1
  fi
else
  echo "curl not installed; install curl to run health checks"
  exit 2
fi
