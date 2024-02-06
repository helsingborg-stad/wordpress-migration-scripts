## WordPress Multisite Migration

This repository contains scripts for migrating WordPress Multisite installations. The migration process involves exporting databases, importing them into a staging environment, and updating domain references.

### Scripts Overview

1. **db-export.sh**: This script exports databases for all sites in the WordPress Multisite network.
   
2. **db-import.sh**: This script imports databases into the staging environment and updates domain references.

3. **update.sh**: This script fetches the latest versions of the migration scripts from the repository. It uses a unique cachebust to ensure the latest scripts are fetched.

### Mu plugin

As this script does not replace or relocate media files, it is crucial to ensure that no files are inadvertently added or deleted from the media directory during migration. This script guarantees the persistence of data and distinguishes between installations. It is recommended to utilize this script under the following circumstances:

- Lack access to modify the web server's system directly.
- Utilize an S3 bucket or a similar external storage solution.

In other scenarios, achieving the same results can be accomplished by mapping the media folder to your production environment in read-only mode. 

### Usage

1. **db-export.sh**:
   - Set the WordPress installation path (`WP_PATH`).
   - Set the destination folder for exported databases (`EXPORT_FOLDER`).
   - Set the WordPress database prefix (`PREFIX`).
   - Run the script to export databases for all sites in the network.

2. **db-import.sh**:
   - Set default values for the domains (`FROM_DOMAIN` and `TO_DOMAIN`).
   - Set the destination folder for imported databases (`IMPORT_FOLDER`).
   - Set the WordPress installation path in the staging environment (`STAGE_WP_PATH`).
   - Run the script with the `blog_id` parameter to import and update domain references for the specified site.

3. **update.sh**:
   - Run the script to fetch the latest versions of the migration scripts from the repository.

### Known Issues

- **Manual Initial Migration**: The initial migration of the database must be done manually. Ensure that the initial setup of the staging environment is performed correctly before using the import script.
  
- **Incomplete Migration of Network-Global Data**: New users, blogs, and other network-global data will not be migrated automatically. Additional steps may be required to synchronize such data between environments.

### Prerequisites

- These scripts assume the presence of WP-CLI for managing WordPress installations via the command line.
- Ensure proper permissions and configurations for database access and file manipulation.

### Additional Notes

- **Colorized Output**: Colored messages are used for clarity in the scripts. Errors are highlighted in red, successful operations in green, and warnings or informational messages in yellow.
- **Safety Measures**: The scripts include error handling and safety measures such as checking for valid parameters and file existence before proceeding with operations.
- **Customization**: Adjust the script variables such as paths, prefixes, and domain names to suit your specific environment and requirements.

### License

This repository is licensed under the [MIT License](LICENSE).

### Contributors

- [Sebastian Thulin](https://github.com/sebastianthulin)

### Issues

For any issues or suggestions regarding these scripts, please open an issue on the [GitHub repository](https://github.com/helsingborg-stad/wordpress-migration-scripts).
