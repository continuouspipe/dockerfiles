#! /usr/bin/env bash

#####
# Perform the Drupal build.
#####
do_drupal_build() {
  do_drupal_create_directories
  do_drupal_permissions
}

#####
# Perform tasks on container start
#####
do_drupal_start() {
  # If you've got a mounted volume, sometimes the permissions won't have been
  # reset, so we should try again now.
  do_drupal_permissions
}

do_drupal_development_start() {
  do_drupal_legacy_development_install_script
  do_drupal_legacy_development_install_finalise_script
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
    # Ensure the files directory is writable.
    chown -R "${CODE_OWNER}":"${APP_GROUP}" "${WEB_DIRECTORY}/modules" "${WEB_DIRECTORY}/profiles" "${WEB_DIRECTORY}/sites/default/files"
    chmod -R ug+rw,o-w "${WEB_DIRECTORY}/modules" "${WEB_DIRECTORY}/profiles" "${WEB_DIRECTORY}/sites/default/files"

    # Ensure the config directory is writeable by the group
    if [ -d /app/config ]; then
      chown -R "${CODE_OWNER}":"${APP_GROUP}" /app/config
      chmod -R ug+rw,o-w /app/config
    fi
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
do_drupal_install() {

  # If we don't want Drupal installed, then return.
  if [ "${INSTALL_DRUPAL}" == 'false' ]; then
    return
  fi

  # Drop the database if we need to force the install every time.
  if [ "${FORCE_DATABASE_DROP}" == 'true' ]; then
    echo 'Dropping the Drupal DB if it exists'
    as_code_owner "drush sql-drop -y -r ${WEB_DIRECTORY}"
  fi

  # If we're supposed to install Drupal, and it's not currently installed,
  # then install it.
  if ! drush status bootstrap -r "${WEB_DIRECTORY}" | grep -q Successful ; then
    echo 'Installing Drupal'

    INSTALL_OPTS="${DRUPAL_INSTALL_PROFILE} --account-name=\"${DRUPAL_ADMIN_USERNAME}\"  --account-pass=\"${DRUPAL_ADMIN_PASSWORD}\" install_configure_form.update_status_module='array(FALSE,FALSE)'"
    # We should make sure this is writeable, but only do it directly before an
    # install. Drupal will lock it back down on install completion.
    chmod -R ug+rw,o-w "${WEB_DIRECTORY}/sites/default/files"
    chmod go+w "${WEB_DIRECTORY}/sites/default/settings.php"
    as_code_owner "drush site-install ${INSTALL_OPTS} -y -r ${WEB_DIRECTORY}"
  fi

}
