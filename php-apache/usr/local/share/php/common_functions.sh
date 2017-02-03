#!/bin/bash

do_build_permissions() {
  if [ "$IS_CHOWN_FORBIDDEN" -ne 0 ]; then
    chown -R "$CODE_OWNER":"$CODE_GROUP" /app/
  else
    chmod -R a+rw /app/
  fi
}

run_composer() {
  if [ -n "$GITHUB_TOKEN" ]; then
    as_code_owner "composer global config github-oauth.github.com '$GITHUB_TOKEN'"
  fi

  as_code_owner "composer install ${COMPOSER_INSTALL_FLAGS}"
  rm -rf /home/build/.composer/cache/
  as_code_owner "composer clear-cache"
}

do_composer() {
  if [ -f "${WORK_DIRECTORY}/composer.json" ]; then
    run_composer
  fi
}

do_composer_postinstall_scripts() {
  as_code_owner 'composer run-script post-install-cmd'
}
