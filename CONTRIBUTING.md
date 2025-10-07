# Contributing to Veraison Documentation

Thank you for your interest in contributing to the Veraison docs. This file gives a
lightweight, focused workflow that helps maintainers review contributions quickly and
ensures a consistent developer experience.

Steps
1. Fork the repository and create a branch named `docs/issue-<number>-<short-desc>`.
2. Make small, focused commits. Prefer one logical change per commit.
3. Run the provided scripts in `scripts/` to validate your environment and examples.
   - `scripts/setup.sh` to install developer prerequisites (non-destructive; prompts before changes).
   - `scripts/validate-setup.sh` to run pre-flight checks.
   - `scripts/quick-start.sh` to run a minimal local demo (requires Docker).
4. Update or add documentation under the appropriate folder (e.g., `api/`, `demo/`, `architecture/`).
5. Add tests or checks where appropriate (examples validation, OpenAPI linting).
6. Push your branch and open a Pull Request against `main` with the issue number in the title.

Pull Request Checklist
- [ ] I followed the contributing guidelines in this file.
- [ ] I ran `scripts/validate-setup.sh` and fixed any issues.
- [ ] The changes are described clearly in the PR description.
- [ ] If the change affects examples or code, I added or updated tests where applicable.

Notes
- Keep changes minimal and avoid large refactors in the same PR.
- If your change needs CI additions (workflows), open a separate PR for the CI work.

If you have questions, ask on the Veraison Zulip: https://veraison.zulipchat.com
