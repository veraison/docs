# CCA Demo: Minimal Placeholder

This folder contains a minimal placeholder `docker-compose.yml` that demonstrates how
to provide a one-command demo orchestration for CCA attestation. It's intentionally
a placeholder and should be replaced with real CCA verification services.

## Quick Start

```bash
cd demo/cca
docker compose up -d
docker compose ps
```

## Health Checks

```bash
# Check CCA verifier
../../scripts/healthcheck.sh http://localhost:8081/ || echo "Service starting..."

# Check CCA provisioning
../../scripts/healthcheck.sh http://localhost:8889/ || echo "Service starting..."
```

## Stop Services

```bash
docker compose down
```

## Next Steps

For the full CCA demo with real attestation:
- See [manual-end-to-end.md](manual-end-to-end.md) for detailed steps
- Replace placeholder services with actual Veraison CCA components
- Update docker-compose.yml with proper service images and configuration
