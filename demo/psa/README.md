# PSA demo: minimal placeholder

This folder contains a minimal placeholder `docker-compose.yml` that demonstrates how
to provide a one-command demo orchestration. It's intentionally tiny and should be
replaced with real demo services for PSA.

Quick start:

```sh
cd demo/psa
docker compose up -d
docker compose ps
```

Health check example:

```sh
./../../scripts/healthcheck.sh http://localhost:8080/health || true
```
