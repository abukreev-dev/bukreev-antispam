<?php
/**
 * Plugin Name: Bukreev Antispam
 * Plugin URI: https://github.com/alexanderbukreev/bukreev-antispam
 * Description: Marks spam comments by static rules without settings or UI.
 * Version: 2.1.1
 * Author: Alexander Bukreev
 * Author URI: https://github.com/alexanderbukreev
 * License: GPL-2.0-or-later
 * License URI: https://www.gnu.org/licenses/gpl-2.0.html
 * Text Domain: bukreev-antispam
 * Requires at least: 5.8
 * Requires PHP: 7.4
 */

if (!defined('ABSPATH')) {
    exit;
}

const BUKREEV_ANTISPAM_VERSION = '2.1.1';
const BUKREEV_ANTISPAM_CRON_HOOK = 'bukreev_antispam_scan_pending_comments';

/**
 * Return spam keywords from the original shell script.
 *
 * @return string[]
 */
function bukreev_antispam_keywords()
{
    return array(
        'free spins',
        'WhatsApp',
        'тел.',
        'yandex.ru',
        'Пишите мне в PM',
        'mail.ru',
        'casino',
        'Loved it',
        'Василенко',
        'writing about',
        'talking about',
        'Gemcy',
        'BTC',
        'спирт',
        'Статья представляет',
        'Собственник',
        'склада',
        'квартиру',
        'ооо',
        'контакты',
        'NON PRY',
        'грузов',
        'казино',
        'Новый год',
        'звоните',
        'звонка',
        'Бествей',
        'пpофиль',
        'http',
        'gmail',
        'заказа',
        'цены',
        'токен',
        'VIP',
        'телефон',
        'SEO',
        'трансфер',
        'цена',
        'Грузоподъемность',
        'товар',
        'отгрузка',
        '1win',
        'Лаки Джет',
        'Lucky',
        '0090=0=',
        'Фонд',
        'СПБ',
        'Viagra',
        'Заработок',
        'мою страничку',
    );
}

/**
 * Return spam authors from the original shell script.
 *
 * @return string[]
 */
function bukreev_antispam_authors()
{
    return array(
        'Thomaszoobe',
        'LouisTib',
        'CurtisLex',
        'LouisCig',
        'GerardoAtMob',
        'JosephKak',
        'Анны Самойлова',
    );
}

/**
 * Check a comment against spam rules from spam-clean-simple.sh.
 *
 * @param array $comment_data Comment payload.
 * @return string Empty string when not spam, otherwise match reason.
 */
function bukreev_antispam_match_reason($comment_data)
{
    $content = isset($comment_data['comment_content']) ? (string) $comment_data['comment_content'] : '';
    $author = isset($comment_data['comment_author']) ? (string) $comment_data['comment_author'] : '';
    $email = isset($comment_data['comment_author_email']) ? (string) $comment_data['comment_author_email'] : '';

    $search_blob = $author . ' ' . $email . ' ' . $content;

    if (stripos($content, '<a href') !== false) {
        return 'HTML link <a href';
    }

    if (!preg_match('/[а-яё]/iu', $content)) {
        return 'no cyrillic characters';
    }

    if (stripos($content, '[url=') !== false) {
        return 'BB-code link [url=';
    }

    foreach (bukreev_antispam_keywords() as $keyword) {
        if ($keyword !== '' && stripos($search_blob, $keyword) !== false) {
            return $keyword;
        }
    }

    foreach (bukreev_antispam_authors() as $author_rule) {
        if ($author_rule !== '' && stripos($search_blob, $author_rule) !== false) {
            return $author_rule;
        }
    }

    return '';
}

/**
 * Mark new comment as spam before insertion when a rule is matched.
 *
 * @param string|int $approved     Current approval status.
 * @param array      $comment_data Comment payload.
 * @return string|int
 */
function bukreev_antispam_pre_comment_approved($approved, $comment_data)
{
    if (bukreev_antispam_match_reason($comment_data) !== '') {
        return 'spam';
    }

    return $approved;
}
add_filter('pre_comment_approved', 'bukreev_antispam_pre_comment_approved', 10, 2);

/**
 * Scan pending comments and mark matched ones as spam.
 * Mirrors shell script behavior for already queued comments.
 *
 * @return void
 */
function bukreev_antispam_scan_pending_comments()
{
    $pending_comments = get_comments(
        array(
            'status' => 'hold',
            'number' => 0,
            'fields' => 'all',
        )
    );

    if (empty($pending_comments)) {
        return;
    }

    foreach ($pending_comments as $comment) {
        $reason = bukreev_antispam_match_reason(
            array(
                'comment_content' => $comment->comment_content,
                'comment_author' => $comment->comment_author,
                'comment_author_email' => $comment->comment_author_email,
            )
        );

        if ($reason === '') {
            continue;
        }

        wp_spam_comment((int) $comment->comment_ID);
    }
}
add_action(BUKREEV_ANTISPAM_CRON_HOOK, 'bukreev_antispam_scan_pending_comments');

/**
 * Setup cron and run an initial scan.
 *
 * @return void
 */
function bukreev_antispam_activate()
{
    if (!wp_next_scheduled(BUKREEV_ANTISPAM_CRON_HOOK)) {
        wp_schedule_event(time(), 'hourly', BUKREEV_ANTISPAM_CRON_HOOK);
    }

    bukreev_antispam_scan_pending_comments();
}
register_activation_hook(__FILE__, 'bukreev_antispam_activate');

/**
 * Remove cron event on plugin deactivation.
 *
 * @return void
 */
function bukreev_antispam_deactivate()
{
    $timestamp = wp_next_scheduled(BUKREEV_ANTISPAM_CRON_HOOK);

    if ($timestamp !== false) {
        wp_unschedule_event($timestamp, BUKREEV_ANTISPAM_CRON_HOOK);
    }
}
register_deactivation_hook(__FILE__, 'bukreev_antispam_deactivate');
