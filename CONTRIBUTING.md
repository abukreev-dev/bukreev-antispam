# Contributing

## Scope
This plugin is intentionally minimal and configuration-free.
Please keep changes aligned with this principle.

## How to Contribute
1. Fork the repository.
2. Create a feature branch from `main`.
3. Make focused changes with clear commit messages.
4. Update `CHANGELOG.md` when behavior or public docs change.
5. Open a Pull Request with:
   - summary of changes
   - rationale
   - test steps

## Coding Notes
- Keep compatibility with supported WordPress/PHP versions from `readme.txt`.
- Avoid adding admin UI or settings unless explicitly requested.
- Keep spam rules deterministic and easy to audit.

## Local Validation
Run basic checks before PR:

```bash
php -l bukreev-antispam.php
php -l uninstall.php
```
