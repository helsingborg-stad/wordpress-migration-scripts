# Generate a unique random cachebust
cache_bust=$(uuidgen)

# Use the random cachebust in the URLs
curl -L "https://raw.githubusercontent.com/helsingborg-stad/wordpress-migration-scripts/main/db-export.sh?$cache_bust" > db-export.sh
curl -L "https://raw.githubusercontent.com/helsingborg-stad/wordpress-migration-scripts/main/db-import.sh?$cache_bust" > db-import.sh
curl -L "https://raw.githubusercontent.com/helsingborg-stad/wordpress-migration-scripts/main/update.sh?$cache_bust" > update.sh