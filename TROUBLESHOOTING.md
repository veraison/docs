# Troubleshooting Guide

This guide covers common issues and platform-specific solutions for working with Veraison documentation.

## Table of Contents

- [Setup Issues](#setup-issues)
- [Docker Issues](#docker-issues)
- [Platform-Specific Issues](#platform-specific-issues)
- [Demo Issues](#demo-issues)
- [Build and Validation Issues](#build-and-validation-issues)

## Setup Issues

### Missing Dependencies

**Problem**: `scripts/validate-setup.sh` reports missing tools.

**Solution**:
```bash
# Run the guided setup
./scripts/setup.sh

# Or install manually:
# Ubuntu/Debian
sudo apt-get update
sudo apt-get install -y docker.io docker-compose-plugin protobuf-compiler shellcheck

# macOS (using Homebrew)
brew install docker docker-compose protobuf shellcheck

# Verify installation
./scripts/validate-setup.sh
```

### protoc Not Found

**Problem**: `protoc: command not found`

**Solution**:
- **Ubuntu/Debian**: `sudo apt-get install -y protobuf-compiler`
- **macOS**: `brew install protobuf`
- **Manual**: Download from https://github.com/protocolbuffers/protobuf/releases

### shellcheck Not Found

**Problem**: `shellcheck: command not found`

**Solution**:
- **Ubuntu/Debian**: `sudo apt-get install -y shellcheck`
- **macOS**: `brew install shellcheck`
- **Windows (WSL)**: `sudo apt-get install -y shellcheck`

## Docker Issues

### Docker Permission Denied

**Problem**: `Got permission denied while trying to connect to the Docker daemon socket`

**Solution**:
```bash
# Add your user to the docker group
sudo usermod -aG docker $USER

# Log out and log back in, or run:
newgrp docker

# Verify
docker ps
```

### Docker Compose Version Issues

**Problem**: `docker-compose: command not found` or version conflicts

**Solution**:
```bash
# Modern Docker includes compose as a plugin
docker compose version

# If using standalone docker-compose v1:
python3 -m pip install --user docker-compose

# Or install the plugin:
sudo apt-get install -y docker-compose-plugin
```

### Port Already in Use

**Problem**: `Bind for 0.0.0.0:8080 failed: port is already allocated`

**Solution**:
```bash
# Find and stop the conflicting process
sudo lsof -i :8080
sudo kill <PID>

# Or change the port in docker-compose.yml
```

## Platform-Specific Issues

### Ubuntu/Debian

**Issue**: Older package versions

**Solution**:
```bash
# Add Docker's official repository for latest versions
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
```

### macOS

**Issue**: Docker Desktop required

**Solution**:
- Install Docker Desktop from https://www.docker.com/products/docker-desktop
- Or use alternatives like OrbStack or Colima

**Issue**: Slow file I/O with Docker volumes

**Solution**:
- Use Docker Desktop's VirtioFS for better performance
- Consider using named volumes instead of bind mounts

### Windows (WSL2)

**Issue**: WSL2 integration not working

**Solution**:
1. Ensure WSL2 is installed: `wsl --install`
2. Enable WSL2 integration in Docker Desktop settings
3. Restart Docker Desktop

**Issue**: Line ending issues

**Solution**:
```bash
# Configure git to handle line endings
git config --global core.autocrlf input
```

## Demo Issues

### PSA Demo Fails to Start

**Problem**: Services fail to start or exit immediately

**Solution**:
```bash
# Check logs
cd demo/psa
docker compose logs

# Rebuild containers
docker compose down
docker compose build --no-cache
docker compose up
```

### CCA Demo Missing Files

**Problem**: Required data files or keys are missing

**Solution**:
```bash
# Ensure you're in the correct directory
cd demo/cca/prov-verif-e2e

# Check that data/keys and data/templates exist
ls -la data/keys/
ls -la data/templates/
```

### Health Check Failures

**Problem**: Services are running but health checks fail

**Solution**:
```bash
# Manual health check
curl http://localhost:8080/health

# Check service logs for errors
docker compose logs <service-name>

# Wait longer for services to start
sleep 10 && ./scripts/healthcheck.sh http://localhost:8080/health
```

## Build and Validation Issues

### Make Validate Fails

**Problem**: `make validate` exits with error

**Solution**:
```bash
# This is expected if tools are missing
# Install missing dependencies first
./scripts/setup.sh

# Then retry
make validate
```

### Shellcheck Reports Issues

**Problem**: `make shellcheck` reports warnings or errors

**Solution**:
- Review the reported issues in your shell scripts
- Most are suggestions for better practices
- Critical issues should be fixed before committing

### OpenAPI Validation Fails

**Problem**: API specs fail validation

**Solution**:
```bash
# Check specific API directory
cd api/challenge-response
make

# Review the error messages
# Common issues: missing required fields, invalid references
```

## Getting Help

If you encounter issues not covered here:

1. Check the [Veraison Zulip channel](https://veraison.zulipchat.com)
2. Review existing GitHub issues: https://github.com/veraison/docs/issues
3. Open a new issue with:
   - Your platform and versions
   - Output from `./scripts/validate-setup.sh`
   - Complete error messages
   - Steps to reproduce
