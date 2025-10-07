# Veraison documentation

## Project Overview

* [Veraison Overview](project-overview.md)
* [Veraison Source Repo Overview](repo-guide.md)

## Services Architecture

* [Introduction Slides](slides/veraison-tmpdev2023.pdf)
* [Provisioning Pipeline](architecture/endorsement-provisioning.md)

## API

* [Evidence Verification via Challenge-Response](api/challenge-response/README.md)
* [Endorsement Provisioning](api/endorsement-provisioning/README.md)
* [Discovery](api/well-known/README.md)

## Data Models

* [Attestation Results](datamodels/attestation-results/README.md)

## Musings

* [DICE notes](musings/dice.md)
* [Device and Supply-Chain Modelling](musings/device-and-supply-chain-modelling.md)
* [Assumptions about Attestation Evidence](musings/token-assumptions.md)
```

## Quick Start

This repository includes comprehensive tooling to improve the developer onboarding experience.
See `CONTRIBUTING.md` for the full workflow.

### 1. Validate Your Environment

```sh
make validate
# or
scripts/validate-setup.sh
```

### 2. Install Missing Dependencies

```sh
scripts/setup.sh
```

### 3. Run Quick Start

```sh
make quick-start
# or
scripts/quick-start.sh
```

### 4. Start Demo Services

```sh
# PSA demo
make demo-psa

# CCA demo
make demo-cca

# Check health
make health-check
```

### 5. Using VS Code?

Open this repository in a devcontainer for a pre-configured development environment:
- Install the "Dev Containers" extension
- Open Command Palette (Ctrl+Shift+P)
- Select "Dev Containers: Reopen in Container"

### Available Make Targets

Run `make help` to see all available commands.

### Troubleshooting

If you encounter issues, see:
- [TROUBLESHOOTING.md](TROUBLESHOOTING.md) - Platform-specific solutions
- [docs/ERROR_HANDLING.md](docs/ERROR_HANDLING.md) - Common error scenarios

### Demo-Specific Instructions

For detailed demo walkthroughs:
- PSA: [demo/psa/](demo/psa/)
- CCA: [demo/cca/](demo/cca/)
