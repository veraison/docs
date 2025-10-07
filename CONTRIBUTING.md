# Contributing to Veraison Documentation

Thank you for your interest in contributing to the Veraison docs. This file gives a
lightweight, focused workflow that helps maintainers review contributions quickly and
ensures a consistent developer experience.

## Getting Started

### Prerequisites

1. Validate your environment:
   ```bash
   make validate
   ```

2. Install missing dependencies:
   ```bash
   ./scripts/setup.sh
   ```

3. (Optional) Use VS Code devcontainer for a pre-configured environment

### Development Workflow

1. **Fork and Branch**
   - Fork the repository
   - Create a branch named `docs/issue-<number>-<short-desc>`
   - Example: `docs/issue-68-onboarding-scripts`

2. **Make Changes**
   - Make small, focused commits (one logical change per commit)
   - Update or add documentation under appropriate folders:
     - `api/` - API specifications
     - `demo/` - Demo walkthroughs
     - `architecture/` - Architecture documentation
     - `scripts/` - Automation scripts

3. **Validate Changes**
   - Run validation: `make validate`
   - Run linting: `make shellcheck` (if modifying scripts)
   - Test demos: `make demo-psa` or `make demo-cca`
   - Run health checks: `make health-check`

4. **Test Documentation**
   - Verify all commands work as documented
   - Test on your platform (Ubuntu/macOS/Windows WSL)
   - Check links and formatting

5. **Submit PR**
   - Push your branch
   - Open a Pull Request against `main`
   - Include issue number in title: `docs: improve setup automation (issue #68)`
   - Fill out the PR checklist

## Pull Request Checklist

Before submitting your PR, ensure:

- [ ] I followed the contributing guidelines in this file
- [ ] I ran `make validate` and fixed any issues
- [ ] I ran `make shellcheck` (if scripts were modified)
- [ ] I tested the changes on my platform
- [ ] The changes are described clearly in the PR description
- [ ] I updated relevant documentation (README, TROUBLESHOOTING, etc.)
- [ ] If adding examples, I verified they work correctly
- [ ] I checked for broken links and formatting issues

## Development Environment

### Using Makefile

```bash
make help          # Show all available targets
make validate      # Validate environment
make shellcheck    # Lint shell scripts
make demo-psa      # Start PSA demo
make demo-cca      # Start CCA demo
make health-check  # Check service health
make clean         # Stop all services
```

### Using Devcontainer

1. Install VS Code and the "Dev Containers" extension
2. Open this repository in VS Code
3. Press Ctrl+Shift+P and select "Dev Containers: Reopen in Container"
4. The environment will be automatically configured

### Manual Setup

Follow the Quick Start section in [README.md](README.md).

## Contribution Guidelines

### Documentation Style

- Use clear, concise language
- Include code examples where helpful
- Provide platform-specific instructions when needed
- Link to related documentation
- Keep formatting consistent

### Script Guidelines

- Use bash/POSIX shell
- Include usage/help text
- Handle errors gracefully
- Be non-destructive (prompt before changes)
- Test on multiple platforms if possible

### Commit Messages

Follow conventional commit format:

```
type: brief description (issue #N)

Longer explanation if needed
```

Types: `docs`, `feat`, `fix`, `chore`, `test`, `refactor`

Examples:
- `docs: add troubleshooting guide (issue #68)`
- `feat: add health check script (issue #68)`
- `fix: correct docker-compose syntax in PSA demo`

### Testing

- Test all commands and examples
- Verify cross-platform compatibility when possible
- Check that demos start successfully
- Run health checks on services

## Troubleshooting

If you encounter issues:

1. Check [TROUBLESHOOTING.md](TROUBLESHOOTING.md) for common problems
2. Review [docs/ERROR_HANDLING.md](docs/ERROR_HANDLING.md) for error scenarios
3. Ask on [Veraison Zulip](https://veraison.zulipchat.com)
4. Open an issue with detailed information

## Code of Conduct

Be respectful and constructive. We're all here to improve Veraison together.

## Questions?

- Zulip: https://veraison.zulipchat.com
- Issues: https://github.com/veraison/docs/issues
- Discussions: https://github.com/veraison/docs/discussions
