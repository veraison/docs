# PSA Demo: Quick Start

This folder contains a placeholder `docker-compose.yml` that demonstrates one-command
demo orchestration for PSA attestation. The services are placeholders and should be
replaced with actual Veraison PSA components.

## Quick Start

### Using Make (Recommended)

```sh
# From repository root
make demo-psa
make health-check
```

### Using Docker Compose Directly

```sh
cd demo/psa
docker compose up -d
docker compose ps
```

## Services

- **Verifier**: Listens on port 8080
- **Provisioning**: Listens on port 8888

## Health Checks

```sh
# Check verifier
../../scripts/healthcheck.sh http://localhost:8080/

# Check provisioning
../../scripts/healthcheck.sh http://localhost:8888/
```

## Stop Services

```sh
docker compose down
# or from repository root:
make clean
```

## Next Steps

For complete PSA demo walkthroughs:
- [Manual End-to-End](manual-end-to-end.md) - Detailed manual workflow
- [Automated End-to-End](automated-end-to-end.md) - Automated testing

## Troubleshooting

See [TROUBLESHOOTING.md](../../TROUBLESHOOTING.md) for common issues.
