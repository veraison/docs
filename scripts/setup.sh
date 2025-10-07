#!/usr/bin/env bash
# scripts/setup.sh - install minimal developer prerequisites (non-destructive)
set -euo pipefail

usage(){
  cat <<EOF
Usage: $(basename "$0") [--dry-run]

Installs or suggests installation steps for common developer dependencies used by the
Veraison documentation (docker, docker-compose, protoc, shellcheck).
This script is conservative: it prints commands and prompts before making changes.
EOF
}

DRY_RUN=0
while [[ ${#} -gt 0 ]]; do
  case "$1" in
    --dry-run) DRY_RUN=1; shift;;
    -h|--help) usage; exit 0;;
    *) echo "Unknown arg: $1"; usage; exit 2;;
  esac
done

echo "Checking common tools..."
need_install=()
check(){
  if ! command -v "$1" >/dev/null 2>&1; then
    need_install+=("$1")
    echo " - $1: MISSING"
  else
    echo " - $1: found ($(command -v "$1"))"
  fi
}

check docker
check docker-compose || check docker-compose
check protoc
check shellcheck

if [[ ${#need_install[@]} -eq 0 ]]; then
  echo "All common tools detected."
  exit 0
fi

echo "\nTools suggested for install: ${need_install[*]}"
if [[ $DRY_RUN -eq 1 ]]; then
  echo "Dry run: not installing anything."
  exit 0
fi

read -r -p "Proceed with printed install suggestions? [y/N] " ans
case "$ans" in
  [Yy]*) ;;
  *) echo "Aborting per user request."; exit 0;;
esac

for t in "${need_install[@]}"; do
  echo "\nSuggested install for: $t"
  case "$t" in
    docker)
      cat <<'CMD'
On Debian/Ubuntu:
  sudo apt-get update && sudo apt-get install -y ca-certificates curl gnupg lsb-release
  curl -fsSL https://download.docker.com/linux/$(. /etc/os-release; echo "$ID")/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  sudo apt-get update && sudo apt-get install -y docker-ce docker-ce-cli containerd.io
CMD
      ;;
    docker-compose)
      cat <<'CMD'
Install via pip (if using compose v1) or use Docker's compose plugin:
  python3 -m pip install --user docker-compose
Or on modern systems:
  sudo apt-get install -y docker-compose-plugin
CMD
      ;;
    protoc)
      echo "Visit https://github.com/protocolbuffers/protobuf/releases and download a release for your OS. On debian/ubuntu: sudo apt-get install -y protobuf-compiler"
      ;;
    shellcheck)
      echo "On Debian/Ubuntu: sudo apt-get install -y shellcheck"
      ;;
    *)
      echo "No automated instruction for $t; please install it using your platform package manager."
      ;;
  esac
done

echo "\nSetup script finished. Re-run 'scripts/validate-setup.sh' to verify the environment."
