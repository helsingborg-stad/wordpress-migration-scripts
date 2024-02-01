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

# Function to display colored messages
color_echo() {
    case $1 in
        red)    echo -e "\e[91m$2\e[0m";;
        green)  echo -e "\e[92m$2\e[0m";;
        yellow) echo -e "\e[93m$2\e[0m";;
        *)      echo $2;;
    esac
}

import_site_database() {
    local BLOG_ID=$1
    local FROM_DOMAIN=$2
    local TO_DOMAIN=$3
    local IMPORT_FILE
    local SEARCH_REPLACE_CMD

    # Check if the BLOG_ID is a valid integer
    if ! [ "$BLOG_ID" -eq "$BLOG_ID" ] 2>/dev/null; then
        # If not a valid integer, exit with an error
        color_echo red "Invalid BLOG_ID '$BLOG_ID'"
        exit 1
    fi

    # Add blog id to prefix.
    if [ "$BLOG_ID" -eq 1 ]; then
        PREFIX=${BASE_PREFIX}
    else
        PREFIX=${BASE_PREFIX}${BLOG_ID}
    fi

    # Define the import file path for each database
    IMPORT_FILE="$IMPORT_FOLDER/${PREFIX}.sql"

    # Check if the import file exists
    if [ ! -f "$IMPORT_FILE" ]; then
        color_echo red "Error: Database file $IMPORT_FILE not found."
        exit 1
    fi

    # Display processing message
    color_echo yellow "Processing site $BLOG_ID:"

    # Change to the WordPress installation directory
    cd "$STAGE_WP_PATH" || exit

    # Run the wp db import command for the current site
    color_echo green "  Importing $IMPORT_FILE to site $BLOG_ID"
    wp db import "$IMPORT_FILE"
    
    # Check if the import was successful
    if [ $? -eq 0 ]; then
        color_echo green "  Success: Imported database for site $BLOG_ID"
    else
        color_echo red "  Error: Failed to import database for site $BLOG_ID"
        exit 1
    fi

    # Perform domain replacement using search-replace CLI
    SEARCH_REPLACE_CMD="wp search-replace '$FROM_DOMAIN' '$TO_DOMAIN' ${PREFIX}_ ${BASE_PREFIX}blogs --network --skip-columns=guid --all-tables"
    color_echo yellow "  Performing domain replacement: $SEARCH_REPLACE_CMD"
    $SEARCH_REPLACE_CMD

    # Check if the search-replace operation was successful
    if [ $? -eq 0 ]; then
        color_echo green "  Success: Domain replacement completed for site $BLOG_ID"
    else
        color_echo red "  Error: Failed to perform domain replacement for site $BLOG_ID"
        exit 1
    fi
}

# Check if the required parameter blog_id is provided
if [ -z "$1" ]; then
    color_echo red "Error: Missing required parameter 'blog_id'"
    exit 1
fi

# Read the blog_id from the command line parameter
BLOG_ID="$1"

# Use default values for domains if not provided
FROM_DOMAIN="${2:-$FROM_DOMAIN}"
TO_DOMAIN="${3:-$TO_DOMAIN}"

# Call the import_site_database function
import_site_database "$BLOG_ID" "$FROM_DOMAIN" "$TO_DOMAIN"
