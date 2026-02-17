#!/bin/bash

###############################################################################
# WordPress Spam Comments Cleaner - Simple Version
# Простая проверка: склеиваем автор+email+текст и ищем совпадения
###############################################################################

# Цвета
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Массивы для поиска (без учета регистра)
SPAM_KEYWORDS=("free spins" "WhatsApp" "тел." "yandex.ru" "Пишите мне в PM" "mail.ru" "casino" "Loved it" "Василенко" "writing about" "talking about" "Gemcy" "BTC" "спирт" "Статья представляет" "Собственник" "склада" "квартиру" "ооо" "контакты" "NON PRY" "грузов" "казино" "Новый год" "звоните" "звонка" "Бествей" "пpофиль" "http" "gmail" "заказа" "цены" "токен" "VIP" "телефон" "SEO" "трансфер" "цена" "Грузоподъемность" "товар" "отгрузка" "1win"  "Лаки Джет" "Lucky" "0090=0=" "Фонд" "СПБ" "Viagra" "Заработок" "мою страничку")
SPAM_AUTHORS=("Thomaszoobe" "LouisTib" "CurtisLex" "LouisCig" "GerardoAtMob" "JosephKak" "Анны Самойлова") 

# Путь к wp-config.php
WP_CONFIG="${1:-./wp-config.php}"

###############################################################################
# Парсинг wp-config.php
###############################################################################

if [ ! -f "$WP_CONFIG" ]; then
    echo -e "${RED}Ошибка: wp-config.php не найден: $WP_CONFIG${NC}"
    exit 1
fi

DB_NAME=$(grep "define.*DB_NAME" "$WP_CONFIG" | sed "s/.*['\"]DB_NAME['\"],\s*['\"]\([^'\"]*\)['\"].*/\1/")
DB_USER=$(grep "define.*DB_USER" "$WP_CONFIG" | sed "s/.*['\"]DB_USER['\"],\s*['\"]\([^'\"]*\)['\"].*/\1/")
DB_PASSWORD=$(grep "define.*DB_PASSWORD" "$WP_CONFIG" | sed "s/.*['\"]DB_PASSWORD['\"],\s*['\"]\([^'\"]*\)['\"].*/\1/")
DB_HOST=$(grep "define.*DB_HOST" "$WP_CONFIG" | sed "s/.*['\"]DB_HOST['\"],\s*['\"]\([^'\"]*\)['\"].*/\1/")
DB_PREFIX=$(grep "table_prefix" "$WP_CONFIG" | sed "s/.*table_prefix\s*=\s*['\"]\([^'\"]*\)['\"].*/\1/")

if [ -z "$DB_NAME" ] || [ -z "$DB_USER" ]; then
    echo -e "${RED}Ошибка: Не удалось извлечь параметры БД${NC}"
    exit 1
fi

DB_PREFIX="${DB_PREFIX:-wp_}"

###############################################################################
# Основная логика
###############################################################################

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}WordPress Spam Cleaner (Simple)${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "База: ${GREEN}$DB_NAME${NC} | Префикс: ${GREEN}$DB_PREFIX${NC}"
echo ""
echo -e "Ключевые слова: ${YELLOW}${SPAM_KEYWORDS[*]}${NC}"
echo -e "Спам-авторы: ${YELLOW}${SPAM_AUTHORS[*]}${NC}"
echo ""

# Получаем ID всех комментариев на модерации
comment_ids=$(mysql -h"$DB_HOST" -u"$DB_USER" -p"$DB_PASSWORD" "$DB_NAME" -sN -e \
    "SELECT comment_ID FROM ${DB_PREFIX}comments WHERE comment_approved = '0'" 2>/dev/null)

if [ -z "$comment_ids" ]; then
    echo -e "${GREEN}Нет комментариев на модерации${NC}"
    exit 0
fi

total=$(echo "$comment_ids" | wc -w)
echo -e "Найдено комментариев: ${YELLOW}$total${NC}"
echo ""

spam_count=0

# Обрабатываем каждый комментарий
for id in $comment_ids; do
    # Получаем контент отдельно для специфичных проверок
    content=$(mysql -h"$DB_HOST" -u"$DB_USER" -p"$DB_PASSWORD" "$DB_NAME" --default-character-set=utf8mb4 -sN -e \
        "SELECT comment_content FROM ${DB_PREFIX}comments WHERE comment_ID = $id" 2>/dev/null)
    
    # Получаем автор + email + контент одной строкой для общего поиска
    data=$(mysql -h"$DB_HOST" -u"$DB_USER" -p"$DB_PASSWORD" "$DB_NAME" --default-character-set=utf8mb4 -sN -e \
        "SELECT CONCAT(
            IFNULL(comment_author, ''), ' ',
            IFNULL(comment_author_email, ''), ' ',
            IFNULL(comment_content, '')
         ) FROM ${DB_PREFIX}comments WHERE comment_ID = $id" 2>/dev/null)
    
    found=""
    
    # Проверка 1: HTML ссылки
    if echo "$content" | grep -q '<a href'; then
        found="HTML ссылка <a href"
    fi
    
    # Проверка 2: Нет русских букв
    if [ -z "$found" ] && ! echo "$content" | grep -q '[а-яА-ЯёЁ]'; then
        found="нет русских букв"
    fi
    
    # Проверка 3: BB-code ссылки
    if [ -z "$found" ] && echo "$content" | grep -q '\[url='; then
        found="BB-code ссылка [url="
    fi
    
    # Проверка 4: Ключевые слова (без учета регистра)    
    for keyword in "${SPAM_KEYWORDS[@]}"; do
        if echo "$data" | grep -qi "$keyword"; then
            found="$keyword"
            break
        fi
    done
    
    # Если не нашли в ключевых словах, проверяем авторов
    if [ -z "$found" ]; then
        for author in "${SPAM_AUTHORS[@]}"; do
            if echo "$data" | grep -qi "$author"; then
                found="$author"
                break
            fi
        done
    fi
    
    # Если что-то нашли - в спам
    if [ -n "$found" ]; then
        mysql -h"$DB_HOST" -u"$DB_USER" -p"$DB_PASSWORD" "$DB_NAME" -e \
            "UPDATE ${DB_PREFIX}comments SET comment_approved = 'spam' WHERE comment_ID = $id" 2>/dev/null
        
        if [ $? -eq 0 ]; then
            echo -e "${YELLOW}[SPAM]${NC} ID: $id - найдено: $found"
            spam_count=$((spam_count + 1))
        fi
    fi
done

# Итоги
echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "Проверено: ${YELLOW}$total${NC}"
echo -e "В спам: ${YELLOW}$spam_count${NC}"
echo -e "Осталось: ${YELLOW}$((total - spam_count))${NC}"
echo -e "${GREEN}========================================${NC}"
