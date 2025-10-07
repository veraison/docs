SHELL := /bin/bash
.PHONY: validate shellcheck quick-start

validate:
	@echo "Running project validation..."
	./scripts/validate-setup.sh

shellcheck:
	@command -v shellcheck >/dev/null 2>&1 || { echo "shellcheck not found"; exit 2; }
	@shellcheck scripts/*.sh || true

quick-start:
	@echo "Quick start (delegates to scripts/quick-start.sh)"
	@./scripts/quick-start.sh
