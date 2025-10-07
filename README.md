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

## Quick start

This repository includes small helper scripts to improve the developer onboarding experience
and address common setup/validation tasks. They are intentionally conservative and
platform-guided. See `CONTRIBUTING.md` for the recommended workflow.

1. Run a quick validation to check your environment:

	```sh
	scripts/validate-setup.sh
	```

2. If tools are missing, either follow the printed suggestions or use the guided setup:

	```sh
	scripts/setup.sh --dry-run
	# or
	scripts/setup.sh
	```

3. To run a minimal quick-start verification (requires Docker):

	```sh
	scripts/quick-start.sh
	```

These scripts are small helpers to make developer onboarding easier. They don't replace
per-demo instructions; please check `demo/` for demo-specific steps (PSA and CCA demos).
