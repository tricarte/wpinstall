#!/usr/bin/env bash

# ##################################################
# A slightly modified version of this gist.
# https://gist.github.com/danielpataki/3b43561f87a3bbb9d33fc8191cc2864f
#
# It is designed to work with DevilBox and requires WPCLI.
# Usage:
# wpinstall.sh directoryName [--locale=en_US] [--plugins]
#
# Run the above command in data/www directory of devilbox.
# It will create a wordpress installation accessable from
# http://directoryName.loc.
#
# If you specify [--plugins] it will also install developer
# related plugins.

# Review "Required variables" and "WP login credentials"
#
# ##################################################

# Required variables
DBHOST="172.16.238.12" # IP address of mysql docker image
DBUSER="root"
DBPASSWORD=""

# WP login credentials
ADMINUSER="admin"
ADMINPASSWORD="123"

# Read directory from params
DIRNAME=$1
WPLANG=$2
INSTALL_PLUGINS=$3

# Derive varibles from directory name
DBNAME="$DIRNAME"
URL="http://$DIRNAME.loc"
TITLE="Welcome:$DIRNAME"

# Colors used
cRed="\e[31m"
cWhite="\e[37m"
cYellow="\e[33m"

if [[ ! $DIRNAME ]]; then
    echo -e "$cRed""You must specify a directory to add""$cWhite"
    exit
fi

if [[ ! -d $DIRNAME ]]; then
    mkdir -p "$DIRNAME/src"
fi

# Change to given directrory
cd "$DIRNAME/src";

echo -e "$cYellow""Installing and configuring now...""$cWhite"

wp core download "$WPLANG"
wp config create \
    --dbname="$DBNAME" \
    --dbhost="$DBHOST" \
    --dbuser="$DBUSER" \
    --dbpass="$DBPASSWORD" \
    --dbcharset=utf8mb4 \
    --force \
    --skip-check \
    --extra-php <<PHP
    define( 'WP_DEBUG', true );
    define( 'WP_DEBUG_LOG', true );
    define( 'SAVEQUERIES', true );
PHP

wp db create

# --force: Overwrite existing files.
# --skip-check: Skip database connection test.
wp core install \
    --url="$URL" \
    --title="$TITLE" \
    --admin_user="$ADMINUSER" \
    --admin_password="$ADMINPASSWORD" \
    --admin_email=me@mydomain.com \
    --skip-email

# Set permalinks to post name.
wp option update permalink_structure "/%postname%/"

if [[ $INSTALL_PLUGINS = "--plugins" ]]; then
    wp plugin install \
        debug-bar \
        debug-bar-console \
        debug-bar-shortcodes \
        debug-bar-constants \
        debug-bar-post-types \
        debug-bar-cron \
        debug-bar-actions-and-filters-addon \
        debug-bar-transients \
        debug-bar-list-dependencies \
        debug-bar-remote-requests \
        query-monitor \
        fancy-admin-ui \
        pluginception \
        monkeyman-rewrite-analyzer \
        user-switching \
        ari-adminer \
        busted \
        wp-log-viewer \
        reset-wp \
        shortcode-finder \
        wpsite-show-ids \
        dark-mode \
        cron-view \
        regenerate-thumbnails \
        --activate
fi

# Create "htdocs" symlink for devilbox.
cd .. && ln -s src htdocs
echo -e "$cYellow""Now you can access your site using the link: $URL.""$cWhite"
xdg-open "$URL/admin" &

# Other developer friendly plugins

# All wordpress admin ui widgets from one place
# including dashicons and jquery ui widgets
# https://github.com/bueltge/WordPress-Admin-Style

# Auto enable dark mode at certain times
# https://gist.github.com/danieltj27/8624d57c5e0f30465f963bc7838bbb7f

# Check that WP sends emails correctly
# https://wordpress.org/plugins/check-email/

# Modify wp_mail() to use a known smtp provider such gmail, mailgun, etc.
# https://wordpress.org/plugins/wp-mail-smtp/

# Reset WordPress database to its original state
# https://wordpress.org/plugins/wordpress-database-reset/ 
