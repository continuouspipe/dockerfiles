#! /usr/bin/env bash

#####
# Perform the Drupal 8 build.
#####
do_drupal_build() {
  do_drupal_create_directories
  do_drupal_permissions
  do_drupal_legacy_install_script
}

do_drupal_development_build() {
  do_drupal_build
  do_drupal_legacy_development_install_script
}

#####
# Perform tasks on container start
#####
do_drupal_start() {
  do_drupal_legacy_install_finalise_script
}

do_drupal_development_start() {
  do_drupal_development_install
  do_drupal_legacy_development_install_script
}

#####
# Create any directories that aren't given by default.
#####
do_drupal_create_directories() {
  mkdir -p "${WEB_DIRECTORY}/sites/default/files"
}

#####
# Fix directory permissions.
#####
do_drupal_permissions() {
  if [ "$IS_CHOWN_FORBIDDEN" -ne 0 ]; then
    # Give the docroot and config directories to the web user.
    chown -R "${APP_USER}":"${APP_GROUP}" "${WEB_DIRECTORY}"

    # Ensure the config directory is writeable by the group
    if [ -d /app/config ]; then
      chmod -R g+w /app/config
      chown -R "${APP_USER}":"${APP_GROUP}" /app/config
    fi

    # Ensure the files directory is writable.
    chmod -R g+w "${WEB_DIRECTORY}/sites/default/files"

    # Setting.php needs to be writable during installation, but Drupal will fix
    # this later.
    chmod go+w "${WEB_DIRECTORY}/sites/default/settings.php"
  fi
}

#####
# Support the legacy install_custom.sh scripts.
#####
do_drupal_legacy_install_script() {
  if [ -f /usr/local/share/drupal/install_custom.sh ]; then
    bash /usr/local/share/drupal/install_custom.sh
  fi
}

do_drupal_legacy_development_install_script() {
  if [ -f /usr/local/share/drupal/development/install_custom.sh ]; then
    bash /usr/local/share/drupal/development/install_custom.sh
  fi
}


####
# Support the legacy install_custom_finalise.sh scripts.
####
do_drupal_legacy_install_finalise_script() {
  if [ -f /usr/local/share/drupal/install_finalise.sh ]; then
    bash /usr/local/share/drupal/install_finalise.sh
  fi
}

do_drupal_legacy_development_install_finalise_script() {
  if [ -f /usr/local/share/drupal/development/install_finalise.sh ]; then
    bash /usr/local/share/drupal/development/install_finalise.sh
  fi
}

#####
# Install Drupal if required.
#####
do_drupal_development_install() {

  if [ "$INSTALL_DRUPAL" == 'false' ]; then
    return
  fi

  # Drop the database if we need to force the install every time.
  if [ "$FORCE_DATABASE_DROP" == 'true' ]; then
    echo 'Dropping the Drupal DB if it exists'
    drush sql-drop -y -r "${WEB_DIRECTORY}"
  fi

  # If we're supposed to install Drupal, and it's not currently installed - then install it.
  if ! drush status bootstrap | grep -q Successful ; then
    echo 'Installing Drupal'
    drush site-install "${DRUPAL_INSTALL_PROFILE}" -y -r "${WEB_DIRECTORY}"
  fi

}