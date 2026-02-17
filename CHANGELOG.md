# Changelog

All notable changes to this project will be documented in this file.

## [2.1.1] - 2026-02-17
- Added explicit documentation for using `spam-clean-simple.sh` in `README.md`, `readme.txt`, and `PROJECT_CONTEXT.md`.
- Added `SECURITY.md` with vulnerability reporting policy.
- Added `CONTRIBUTING.md` with contribution workflow.

## [2.1.0] - 2026-02-17
- Added standard WordPress plugin package files: `readme.txt`, `index.php`, `uninstall.php`, `LICENSE`, `.gitignore`.
- Updated plugin header metadata in `bukreev-antispam.php` (License, License URI, Text Domain, Author URI).
- Bumped plugin version to `2.1.0`.
- Synchronized project documentation with standard plugin structure.

## [2.0.0] - 2026-02-17
- Rebuilt plugin as `bukreev-antispam.php` with static anti-spam rules migrated from `spam-clean-simple.sh`.
- Added automatic spam marking for new comments via `pre_comment_approved` filter.
- Added scheduled scan of pending comments (hourly WP-Cron) to mirror shell script moderation queue cleanup.
- Removed legacy behavior that blocked comments directly and replaced it with spam status assignment.
