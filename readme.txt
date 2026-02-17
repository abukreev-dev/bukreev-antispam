=== Bukreev Antispam ===
Contributors: alexanderbukreev
Tags: comments, spam, antispam, moderation
Requires at least: 5.8
Tested up to: 6.8
Requires PHP: 7.4
Stable tag: 2.1.0
License: GPLv2 or later
License URI: https://www.gnu.org/licenses/gpl-2.0.html

Marks spam comments by fixed rules from the project shell script, without settings pages.

== Description ==
Bukreev Antispam marks comments as spam using a fixed rule set.

It does not add settings screens or admin UI.

Rule groups:
- HTML links (`<a href`)
- No Cyrillic characters in comment text
- BBCode links (`[url=`)
- Static keyword list
- Static author list

== Installation ==
1. Upload the plugin folder to `/wp-content/plugins/`.
2. Activate `Bukreev Antispam` through the Plugins menu in WordPress.

== Frequently Asked Questions ==
= Does this plugin have settings? =
No. The rule set is hardcoded in the plugin file.

== Changelog ==
= 2.1.0 =
- Added standard WordPress plugin package files (`readme.txt`, `index.php`, `uninstall.php`, `LICENSE`, `.gitignore`).
- Added complete plugin header metadata (`License`, `Text Domain`, `Author URI`).

= 2.0.0 =
- Migrated anti-spam rules from `spam-clean-simple.sh` into plugin runtime logic.
