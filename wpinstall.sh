#!/usr/bin/env bash
set -e

# ##################################################
# A slightly modified version of this gist.
# https://gist.github.com/danielpataki/3b43561f87a3bbb9d33fc8191cc2864f
#
# Usage:
# wpinstall.sh directoryName [--locale=en_US] [--plugins]
#
# Note that arguments are positional not named.
#
# It will create a wordpress installation accessable from
#
# If you specify [--plugins] it will also install developer
# related plugins.
#
#
# ##################################################

read -p "Database host: " DBHOST
read -p "Database user: " DBUSER
read -sp "Password for the database user: " DBPASSWORD
echo
read -p "Login name for admin user: " ADMINUSER
read -sp "Password for admin user: " ADMINPASSWORD
# FIXME: enter again
echo
read -p "Full site url: " URL
read -p "Email addres for admin user: " EMAIL
read -p "Enter database prefix: (eg: wp_): " DBPREFIX

# Read directory from params
DIRNAME=$1

if [ -z "$2" ]; then
    WPLANG="--locale=en_US"
else
    WPLANG="$2"
fi

INSTALL_PLUGINS=$3

# Derive varibles from directory name
DBNAME="$DIRNAME"
# URL="http://$DIRNAME.loc"
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
    mkdir -p "$DIRNAME"
fi

# Change to given directrory
cd "$DIRNAME" || exit

echo -e "$cYellow""Installing and configuring now...""$cWhite"

wp core download "$WPLANG"
wp config create \
    --dbname="$DBNAME" \
    --dbhost="$DBHOST" \
    --dbuser="$DBUSER" \
    --dbpass="$DBPASSWORD" \
    --dbcharset=utf8mb4 \
    --dbprefix="$DBPREFIX" \
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
    --admin_email="$EMAIL" \
    --skip-email

# Set permalinks to post name.
wp option update permalink_structure "/%postname%/"

# Rename "Uncategorized" to "General"
wp term update category 1 --slug=general --name=General

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
        fast-user-switching \
        ari-adminer \
        busted \
        wp-log-viewer \
        wp-reset \
        shortcode-finder \
        wpsite-show-ids \
        dark-mode \
        cron-view \
        regenerate-thumbnails \
        postem-ipsum \
        --activate
fi

# Create "htdocs" symlink for devilbox.
echo -e "$cYellow""Now you can access your site using the link: $URL.""$cWhite"

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

# Reset WordPress database to its original state.
# Another database reset plugin other than wp-reset.
# https://wordpress.org/plugins/wordpress-database-reset/

# Text editor with simple file manager.
# https://wordpress.org/plugins/aceide/
