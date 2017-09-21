#!/bin/bash

do_build_permissions() {
  if [ "$IS_CHOWN_FORBIDDEN" != 'true' ]; then
    chown -R "$CODE_OWNER":"$CODE_GROUP" /app/
  else
    chmod -R a+rw /app/
  fi
}

do_composer_config() (
  set +x
  if [ -n "$GITHUB_TOKEN" ]; then
    as_code_owner "composer global config github-oauth.github.com '$GITHUB_TOKEN'"
  fi
)

run_composer() {
  as_code_owner "composer install ${COMPOSER_INSTALL_FLAGS}"
}

do_composer() {
  if [ -f "${WORK_DIRECTORY}/composer.json" ]; then
    do_composer_config
    run_composer
    do_composer_clear_cache
  fi
}

do_composer_clear_cache() {
  rm -rf /home/build/.composer/cache/
  as_code_owner "composer clear-cache"
}

do_composer_postinstall_scripts() {
  as_code_owner 'composer run-script post-install-cmd'
}

has_composer_package() {
  if [ ! -f "${WORK_DIRECTORY}/composer.lock" ]; then
    return
  fi

  is_true "$(jq -c '(.packages + .["packages-dev"])[] | select(.name == "'"$1"'") | has("name")' "${WORK_DIRECTORY}/composer.lock")"
  return "$?"
}

composer_package_version() {
  local -r PACKAGE_VERSION="$(jq -c '(.packages + .["packages-dev"])[] | select(.name == "'"$1"'") | .version' "${WORK_DIRECTORY}/composer.lock" | sed 's/^"v\?\(.*\)"/\1/')"

  if [ -z "${PACKAGE_VERSION}" ]; then
    return 1
  fi

  echo "${PACKAGE_VERSION}"
}

composer_package_compare() {
  local -r PACKAGE="$1"
  local -r RELATION="$2"
  local -r COMPARE_VERSION="$3"
  local -r PACKAGE_VERSION="$(composer_package_version "${PACKAGE}")"

  if [ -z "${PACKAGE_VERSION}" ]; then
    return 1
  fi

  dpkg --compare-versions "${PACKAGE_VERSION}" "${RELATION}" "${COMPARE_VERSION}"
  return "$?"
}
