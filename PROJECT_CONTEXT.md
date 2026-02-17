# Project Context

## Goal
Convert the standalone spam-cleaning shell logic into a minimal, standard WordPress plugin package with no configuration screens and no settings.

## Source of Truth for Rules
`spam-clean-simple.sh`

## Implemented in Plugin
`bukreev-antispam.php`

## Current Behavior
- Applies spam rules to each incoming comment via `pre_comment_approved`.
- If at least one rule matches, comment status is set to `spam`.
- Runs hourly scan via WP-Cron for comments with `hold` status and marks matches as spam.
- Runs initial pending-comments scan on plugin activation.
- Unschedules plugin cron hook during uninstall.
- Keeps standalone script workflow available for manual DB cleanup.

## Rule Set (ported as-is)
1. Comment contains `<a href`
2. Comment text has no Cyrillic letters
3. Comment contains `[url=`
4. Any static keyword match in author/email/content blob
5. Any static author match in author/email/content blob

## Standard Package Files
- `bukreev-antispam.php` (main plugin runtime)
- `readme.txt` (WordPress plugin metadata)
- `index.php` (directory access protection)
- `uninstall.php` (cleanup hook)
- `LICENSE` (GPL-2.0-or-later text)
- `README.md` (developer-oriented overview)
- `CHANGELOG.md` (release history)
- `.gitignore` (local artifact ignore list)
- `spam-clean-simple.sh` (original standalone cleaner and rule source)

## Shell Script Workflow
- Script: `spam-clean-simple.sh`
- Purpose: manual one-off cleanup of pending comments directly in DB using the same rule set.
- Run:
  - `./spam-clean-simple.sh /path/to/wp-config.php`
  - `./spam-clean-simple.sh` (expects `./wp-config.php`)
- Output: reports checked/spam/remaining counters and moves matches to `comment_approved = 'spam'`.
