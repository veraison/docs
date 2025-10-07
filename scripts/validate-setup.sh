#!/usr/bin/env bash
# scripts/validate-setup.sh - run pre-flight checks for documentation developer environment
set -euo pipefail

echo "Running pre-flight checks for Veraison docs development environment"
missing=0
check(){
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "[FAIL] Missing: $1"
    missing=1
  else
    echo "[ OK ] Found: $1 -> $(command -v "$1")"
  fi
}

# Check for Docker (required)
check docker

# Check for docker-compose (v1) or docker compose plugin (v2)
if command -v docker-compose >/dev/null 2>&1; then
  echo "[ OK ] Found: docker-compose -> $(command -v docker-compose)"
elif docker compose version >/dev/null 2>&1; then
  echo "[ OK ] Found: docker compose (plugin)"
else
  echo "[WARN] docker-compose not found (optional, demos may not work)"
fi

# Check optional tools
if command -v protoc >/dev/null 2>&1; then
  echo "[ OK ] Found: protoc -> $(command -v protoc)"
else
  echo "[WARN] protoc not found (optional)"
fi

if command -v shellcheck >/dev/null 2>&1; then
  echo "[ OK ] Found: shellcheck -> $(command -v shellcheck)"
else
  echo "[WARN] shellcheck not found (optional)"
fi

if [[ $missing -ne 0 ]]; then
  echo "One or more required tools are missing. Run scripts/setup.sh for guidance."
  exit 2
fi

echo "All required tools appear installed."
