#! /usr/bin/env bash

#####
# Perform the Drupal 8 build.
#####
do_drupal8_build() {
  do_drupal8_create_directories
  do_drupal8_deck_build
  do_drupal8_permissions
}

#####
# Create any directories that aren't given by default.
#####
do_drupal8_create_directories() {
  mkdir -p /app/sites/default/files
}

#####
# Fix directory permissions.
#####
do_drupal8_permissions() {
  if [ "$IS_CHOWN_FORBIDDEN" -ne 0 ]; then
    # Give the docroot to the web user.
    chown -R "${APP_USER}":"${APP_GROUP}" /app/docroot

    # Ensure the files directory is writable.
    chmod g+w /app/sites/default/files

    # Setting.php needs to be writable during installation, but Drupal will fix
    # this later.
    chmod go+w /app/sites/default/settings.php
  fi
}

#####
# Build the front end assets, but only if the Deck tools exist.
#
# Todo: Make this a little more customisable for users who aren't using the
# Deck theme tools.
#####
do_drupal8_deck_build() {
  # If the Deck tools exist, then run them.
  if [ -f /app/gulp/gulpfile.js ]; then
    as_code_owner "npm install"
    as_code_owner "node_modules/.bin/gulp build"
  fi
}
