#!/bin/bash

# Set the default values for domains
FROM_DOMAIN="helsingborg.se"
TO_DOMAIN="hbgtest.se"

# Set the destination folder for imported databases
IMPORT_FOLDER="/var/db"

# Set the path to the WordPress installation in the staging environment
STAGE_WP_PATH="/var/www/stage"

# Set the prefix variable
BASE_PREFIX="hbg_"

color_echo() {
    case $1 in
        red)    echo "\e[91m$2\e[0m";;
        green)  echo "\e[92m$2\e[0m";;
        yellow) echo "\e[93m$2\e[0m";;
        *)      echo $2;;
    esac
}

import_site_database() {
    local BLOG_ID=$1
    local FROM_DOMAIN=$2
    local TO_DOMAIN=$3
    local IMPORT_FILE
    local SEARCH_REPLACE_CMD

    if ! [ "$BLOG_ID" -eq "$BLOG_ID" ] 2>/dev/null; then
        color_echo red "Invalid BLOG_ID '$BLOG_ID'"
        exit 1
    fi

    if [ "$BLOG_ID" -eq 1 ]; then
        PREFIX=${BASE_PREFIX}
    else
        PREFIX=${BASE_PREFIX}${BLOG_ID}
    fi

    IMPORT_FILE="$IMPORT_FOLDER/${PREFIX}.sql"

    if [ ! -f "$IMPORT_FILE" ]; then
        color_echo red "Error: Database file $IMPORT_FILE not found."
        exit 1
    fi

    color_echo yellow "Processing site $BLOG_ID:"
    cd "$STAGE_WP_PATH" || exit

    color_echo green "  Importing $IMPORT_FILE to site $BLOG_ID"
    wp db import "$IMPORT_FILE"
    
    if [ $? -eq 0 ]; then
        wp cache flush
    else
        color_echo red "Error: Failed to import database for site $BLOG_ID"
        exit 1
    fi

    if [ "$BLOG_ID" -eq 1 ]; then
        TABLES=$(wp db tables --scope=blog  | tr '\n' ' ')
        SEARCH_REPLACE_CMD="wp search-replace $FROM_DOMAIN $TO_DOMAIN ${TABLES} ${BASE_PREFIX}blogs --network --skip-columns=guid --all-tables"
    else
        SEARCH_REPLACE_CMD="wp search-replace $FROM_DOMAIN $TO_DOMAIN ${PREFIX}_* ${BASE_PREFIX}blogs --network --skip-columns=guid --all-tables"
    fi

    color_echo yellow "  Performing domain replacement: $SEARCH_REPLACE_CMD"
    $SEARCH_REPLACE_CMD

    if [ $? -eq 0 ]; then
        wp cache flush
    else
        color_echo red "Error: Failed to perform domain replacement for site $BLOG_ID"
        exit 1
    fi
}

if [ -z "$1" ]; then
    color_echo red "Error: Missing required parameter 'blog_id'"
    exit 1
fi

BLOG_ID="$1"
FROM_DOMAIN="${2:-$FROM_DOMAIN}"
TO_DOMAIN="${3:-$TO_DOMAIN}"

import_site_database "$BLOG_ID" "$FROM_DOMAIN" "$TO_DOMAIN"
