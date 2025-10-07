#!/usr/bin/env bash
# scripts/quick-start.sh - minimal quick start for local evaluation (requires Docker)
set -euo pipefail

if ! command -v docker >/dev/null 2>&1; then
  echo "Docker is required for quick-start. Please install Docker or run 'scripts/setup.sh'"
  exit 2
fi

echo "Starting a minimal quick-start environment using Docker."

echo "Pulling a small busybox image as a placeholder demo (no network services are required)."
docker pull busybox:latest >/dev/null

echo "Running a quick command inside a short-lived container to verify Docker works."
docker run --rm busybox:latest echo "Quick-start: docker run succeeded"

echo "Quick-start finished. This repository's demos require more specific images and compose files which
should be added per-demo under 'demo/'. See demo/psa/ and demo/cca/ for example workflows."
