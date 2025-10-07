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

check docker
check docker-compose || true
check protoc || true
check shellcheck || true

if [[ $missing -ne 0 ]]; then
  echo "One or more required tools are missing. Run scripts/setup.sh for guidance."
  exit 2
fi

echo "All required tools appear installed."
