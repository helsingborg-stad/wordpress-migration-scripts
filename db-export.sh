#!/bin/bash

# Set the path to the WordPress installation
WP_PATH="/var/www/prod"

# Set the destination folder for exported databases
EXPORT_FOLDER="/var/db"

# Set the WordPress db prefix
PREFIX="hbg_"

# Change the current directory to the WordPress installation
cd "$WP_PATH" || exit

# Get a list of all sites in the network
SITES=$(wp site list --format=csv | tail -n +2)

# Function to display colored messages
color_echo() {
    case $1 in
        red)    echo -e "\e[91m$2\e[0m";;
        green)  echo -e "\e[92m$2\e[0m";;
        yellow) echo -e "\e[93m$2\e[0m";;
        *)      echo $2;;
    esac
}

# Loop through each site and export the corresponding database
echo "$SITES" | while IFS=, read -r BLOG_ID URL LAST_UPDATED REGISTERED; do
    # Check if the BLOG_ID is a valid integer
    if ! [ "$BLOG_ID" -eq "$BLOG_ID" ] 2>/dev/null; then
        # If not a valid integer, skip this iteration
        color_echo red "Skipping invalid BLOG_ID '$BLOG_ID'"
        continue
    fi

    # Conditionally set the prefix based on BLOG_ID
    if [ "$BLOG_ID" -eq 1 ]; then
        # Combine the prefix without the blog ID
        PREFIX_WITH_BLOG_ID="${PREFIX}"
    else
        # Combine the prefix with the blog ID
        PREFIX_WITH_BLOG_ID="${PREFIX}${BLOG_ID}"
    fi

    # Display processing message
    color_echo yellow "Processing site $BLOG_ID:"

    # Get a list of tables matching the current site prefix
    if [ "$BLOG_ID" -eq 1 ]; then
        TABLES=$(wp db tables --format=csv)
    else
        TABLES=$(wp db tables "${PREFIX_WITH_BLOG_ID}*" --format=csv --all-tables)
    fi

    # Check if any tables are found
    if [ -n "$TABLES" ]; then
        # Define the export file path for each database
        EXPORT_FILE="$EXPORT_FOLDER/$PREFIX_WITH_BLOG_ID.sql"

        # Run the wp db export command for the current site prefix
        EXPORT_FILE_TMP="$WP_PATH/$(wp db export --tables="$TABLES" --porcelain)"

        #Move
        color_echo green "  Moving $EXPORT_FILE_TMP to $EXPORT_FILE"
        mv -i -f $EXPORT_FILE_TMP $EXPORT_FILE

        # Check if the export was successful
        if [ $? -eq 0 ]; then
            color_echo green "  Success: Exported $PREFIX_WITH_BLOG_ID database for site $BLOG_ID to $EXPORT_FILE"
        else
            color_echo red "  Error: Failed to export $PREFIX_WITH_BLOG_ID database for site $BLOG_ID"
        fi
    else
        color_echo yellow "  Warning: No tables found for prefix $PREFIX_WITH_BLOG_ID in site $BLOG_ID"
    fi
done
