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
  if [ "$IS_CHOWN_FORBIDDEN" != 'true' ]; then
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
    (
      set +x
      INSTALL_OPTS="${DRUPAL_INSTALL_PROFILE} --account-name=\"${DRUPAL_ADMIN_USERNAME}\"  --account-pass=\"${DRUPAL_ADMIN_PASSWORD}\" install_configure_form.update_status_module='array(FALSE,FALSE)'"
      # We should make sure this is writeable, but only do it directly before an
      # install. Drupal will lock it back down on install completion.
      chmod -R ug+rw,o-w "${WEB_DIRECTORY}/sites/default/files"
      chmod go+w "${WEB_DIRECTORY}/sites/default/settings.php"
      as_code_owner "drush site-install ${INSTALL_OPTS} -y -r ${WEB_DIRECTORY}"
    )
  fi

}

####
# Ability to sync a database dump from a remote server that is accessible via SSH.
# Plus apply the database dump and sanitise it.
####
do_drupal_sync_database() {
  do_drupal_setup_sync_ssh_keys
  do_drupal_sync_database_backup_via_ssh
  do_drupal_database_restore
  do_drupal_database_sanitise
}

####
# Provide SSH keys so that do_drupal_sync_database_backup_via_ssh can function
####
do_drupal_setup_sync_ssh_keys() (
  set +x
  do_user_ssh_keys "build" "${DRUPAL_SYNC_SSH_KEY_NAME}" "${DRUPAL_SYNC_SSH_PRIVATE_KEY}" "${DRUPAL_SYNC_SSH_PUBLIC_KEY}" "${DRUPAL_SYNC_SSH_KNOWN_HOSTS}"
  unset DRUPAL_SYNC_SSH_PRIVATE_KEY
  unset DRUPAL_SYNC_SSH_PRIVATE_KEY
  unset DRUPAL_SYNC_SSH_KNOWN_HOSTS
)

####
# Ability to sync a database dump from a remote server that is accessible via SSH.
####
do_drupal_sync_database_backup_via_ssh() {
  if [ -z "${DRUPAL_SYNC_SSH_KEY_NAME}" ] || [ -z "${DRUPAL_SYNC_SSH_SERVER_PORT}" ] || [ -z "${DRUPAL_SYNC_SSH_USERNAME}" ] || [ -z "${DRUPAL_SYNC_SSH_SERVER_HOST}" ] || [ -z "${DRUPAL_SYNC_DATABASE_FILENAME_GLOB}" ] || [ -z "${DATABASE_ARCHIVE_PATH}" ]; then
    return 1
  fi

  echo 'Work out which file is the latest backup'
  local DATABASE_BACKUP_REMOTE_PATH
  DATABASE_BACKUP_REMOTE_PATH="$(as_build "ssh -i '/home/build/.ssh/${DRUPAL_SYNC_SSH_KEY_NAME}' -p '${DRUPAL_SYNC_SSH_SERVER_PORT}' '${DRUPAL_SYNC_SSH_USERNAME}@${DRUPAL_SYNC_SSH_SERVER_HOST}' 'ls -t ${DRUPAL_SYNC_DATABASE_FILENAME_GLOB} | head -1'")"

  echo 'Copy the database from the remote server to the container'
  as_build "scp -i '/home/build/.ssh/${DRUPAL_SYNC_SSH_KEY_NAME}' -P '${DRUPAL_SYNC_SSH_SERVER_PORT}' '${DRUPAL_SYNC_SSH_USERNAME}@${DRUPAL_SYNC_SSH_SERVER_HOST}:${DATABASE_BACKUP_REMOTE_PATH}' '${DATABASE_ARCHIVE_PATH}'"
}

#####
# Restore a database if required.
# Not triggered by default, please call from a function in your plan.sh to use.
#####
do_drupal_database_restore() (
  set +x
  if [ -f "$DATABASE_ARCHIVE_PATH" ]; then
    local DATABASE_ARGS=(-h"$DATABASE_HOST")

    if [ -n "$DATABASE_ADMIN_USER" ]; then
      DATABASE_ARGS+=(-u"$DATABASE_ADMIN_USER" -p"$DATABASE_ADMIN_PASSWORD")
    else
      DATABASE_ARGS+=(-u"$DATABASE_USER" -p"$DATABASE_PASSWORD")
    fi

    if [ "$FORCE_DATABASE_DROP" == 'true' ]; then
      echo 'Dropping the Drupal DB if it exists'
      mysql "${DATABASE_ARGS[@]}" -e "DROP DATABASE IF EXISTS $DATABASE_NAME" || return 1
    fi

    set +e
    mysql "${DATABASE_ARGS[@]}" "$DATABASE_NAME" -e "SHOW TABLES; SELECT FOUND_ROWS() > 0;" | grep -q 1
    DATABASE_EXISTS=$?
    set -e

    if [ "$DATABASE_EXISTS" -ne 0 ]; then
      echo 'Create Drupal database'
      echo "CREATE DATABASE IF NOT EXISTS $DATABASE_NAME" |  mysql "${DATABASE_ARGS[@]}"

      if [ -n "${DATABASE_ROOT_PASSWORD:-}" ]; then
        echo "deprecated: granting $DATABASE_USER mysql user access should be moved to mysql service's environment variables and DATABASE_ROOT_PASSWORD removed from this service"
        echo "GRANT ALL ON $DATABASE_NAME.* TO $DATABASE_USER@'%' IDENTIFIED BY '$DATABASE_PASSWORD' ; FLUSH PRIVILEGES" |  mysql "${DATABASE_ARGS[@]}"
      fi

      echo 'zcating the drupal database dump into the database'
      zcat "$DATABASE_ARCHIVE_PATH" | mysql "${DATABASE_ARGS[@]}" "$DATABASE_NAME" || return 1
    fi
  fi
)

do_drupal_database_sanitise() {
  as_code_owner "drush ${DRUPAL_DRUSH_ALIAS} sql-sanitize --yes -r ${WEB_DIRECTORY}"
}

###
# Run the drupal composer extension installer.
# Not triggered by default.
###
do_drupal_composer_install() {
  echo "Ensuring Drupal Composer extension is up-to-date..."
  as_code_owner "drush ${DRUPAL_DRUSH_ALIAS} dl composer-8.x-1.x -y" /app/docroot

  echo "Running Composer..."
  as_code_owner "drush ${DRUPAL_DRUSH_ALIAS} cc drush" /app/docroot
  as_code_owner "drush ${DRUPAL_DRUSH_ALIAS} composer-json-rebuild" /app/docroot
  as_code_owner "drush ${DRUPAL_DRUSH_ALIAS} composer-execute install --no-dev" /app/docroot
  as_code_owner "drush ${DRUPAL_DRUSH_ALIAS} composer-execute dump-autoload -o" /app/docroot
}
