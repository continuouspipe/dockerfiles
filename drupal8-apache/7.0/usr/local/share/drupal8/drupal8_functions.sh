#! /usr/bin/env bash

#####
# Perform the Drupal 8 build.
#####
do_drupal8_build() {
  do_drupal8_create_directories
  do_drupal8_deck_build
  do_drupal8_permissions
  do_drupal8_legacy_install_script
}

do_drupal8_development_build() {
  do_drupal8_build
  do_drupal8_legacy_development_install_script
}

#####
# Perform tasks on container start
#####
do_drupal8_start() {
  do_drupal8_permissions
  do_drupal8_legacy_install_finalise_script
}

do_drupal8_development_start() {
  do_drupal8_start
  do_drupal8_legacy_development_install_script
}

#####
# Create any directories that aren't given by default.
#####
do_drupal8_create_directories() {
  mkdir -p "${WEB_DIRECTORY}/sites/default/files"
}

#####
# Fix directory permissions.
#####
do_drupal8_permissions() {
  if [ "$IS_CHOWN_FORBIDDEN" -ne 0 ]; then
    # Give the docroot and config directories to the web user.
    chown -R "${APP_USER}:${APP_GROUP} ${WEB_DIRECTORY}"
    chown -R "${APP_USER}:${APP_GROUP} /app/config"

    # Ensure the files directory is writable.
    chmod -R g+w "${WEB_DIRECTORY}/sites/default/files"

    # Ensure the config directory is writeable by the group
    chmod -R g+w /app/config

    # Setting.php needs to be writable during installation, but Drupal will fix
    # this later.
    chmod go+w "${WEB_DIRECTORY}/sites/default/settings.php"
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
    cd /app/gulp || return
    as_code_owner "npm install"
    as_code_owner "node_modules/.bin/gulp build"
  fi
}

####
# Support the legacy install_custom.sh scripts.
####
do_drupal8_legacy_install_script() {
  if [ -f /usr/local/share/drupal8/install_custom.sh ]; then
    bash /usr/local/share/drupal8/install_custom.sh
  fi
}

do_drupal8_legacy_development_install_script() {
  if [ -f /usr/local/share/drupal8/development/install_custom.sh ]; then
    bash /usr/local/share/drupal8/development/install_custom.sh
  fi
}


####
# Support the legacy install_custom_finalise.sh scripts.
####
do_drupal8_legacy_install_finalise_script() {
  if [ -f /usr/local/share/drupal8/install_finalise.sh ]; then
    bash /usr/local/share/drupal8/install_finalise.sh
  fi
}

do_drupal8_legacy_development_install_finalise_script() {
  if [ -f /usr/local/share/drupal8/development/install_finalise.sh ]; then
    bash /usr/local/share/drupal8/development/install_finalise.sh
  fi
}