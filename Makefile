SHELL := /bin/bash
.PHONY: help validate shellcheck quick-start demo-psa demo-cca health-check clean

help:
	@echo "Veraison Documentation - Available targets:"
	@echo "  make validate      - Run environment validation checks"
	@echo "  make shellcheck    - Run shellcheck on all scripts"
	@echo "  make quick-start   - Run quick-start verification"
	@echo "  make demo-psa      - Start PSA demo services"
	@echo "  make demo-cca      - Start CCA demo services"
	@echo "  make health-check  - Check health of running services"
	@echo "  make clean         - Stop all demo services"
	@echo ""
	@echo "For troubleshooting, see TROUBLESHOOTING.md"

validate:
	@echo "Running project validation..."
	@./scripts/validate-setup.sh

shellcheck:
	@echo "Running shellcheck on scripts..."
	@command -v shellcheck >/dev/null 2>&1 || { echo "shellcheck not found, install it for better validation"; exit 0; }
	@shellcheck scripts/*.sh || true

quick-start:
	@echo "Quick start (delegates to scripts/quick-start.sh)"
	@./scripts/quick-start.sh

demo-psa:
	@echo "Starting PSA demo services..."
	@cd demo/psa && docker compose up -d
	@echo "Services started. Check status with: cd demo/psa && docker compose ps"

demo-cca:
	@echo "Starting CCA demo services..."
	@cd demo/cca && docker compose up -d
	@echo "Services started. Check status with: cd demo/cca && docker compose ps"

health-check:
	@echo "Checking service health..."
	@./scripts/healthcheck.sh http://localhost:8080/ || echo "PSA verifier not responding"
	@./scripts/healthcheck.sh http://localhost:8888/ || echo "PSA provisioning not responding"
	@./scripts/healthcheck.sh http://localhost:8081/ || echo "CCA verifier not responding"
	@./scripts/healthcheck.sh http://localhost:8889/ || echo "CCA provisioning not responding"

clean:
	@echo "Stopping all demo services..."
	@cd demo/psa && docker compose down 2>/dev/null || true
	@cd demo/cca && docker compose down 2>/dev/null || true
	@echo "Services stopped."
