# Bukreev Antispam

WordPress plugin that marks comments as spam using a fixed set of rules from `spam-clean-simple.sh`.

## What It Does
- Checks every new comment before approval.
- Marks matched comments as `spam` (does not show any UI or settings page).
- Scans all pending comments every hour and moves matches to spam.
- Uses exactly these rule groups:
  - HTML link pattern: `<a href`
  - No Cyrillic letters in comment text
  - BBCode link pattern: `[url=`
  - Static keyword list
  - Static author list

## Standard Plugin Files
- Main plugin file: `bukreev-antispam.php`
- WordPress.org metadata: `readme.txt`
- Directory protection file: `index.php`
- Cleanup on uninstall: `uninstall.php`
- License file: `LICENSE`
- Change log: `CHANGELOG.md`
- Project context: `PROJECT_CONTEXT.md`

## Version
Current plugin version: `2.1.0`

## Notes
- The plugin is intentionally configuration-free.
- Rule lists are hardcoded in `bukreev-antispam.php`.
