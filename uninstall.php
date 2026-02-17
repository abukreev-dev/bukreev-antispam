<?php
/**
 * Uninstall file for Bukreev Antispam.
 */

if (!defined('WP_UNINSTALL_PLUGIN')) {
    exit;
}

$timestamp = wp_next_scheduled('bukreev_antispam_scan_pending_comments');
if ($timestamp !== false) {
    wp_unschedule_event($timestamp, 'bukreev_antispam_scan_pending_comments');
}
