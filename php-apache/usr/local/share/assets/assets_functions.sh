#!/bin/bash

function do_assets_download()
{
  if [ -n "${ASSETS_PATH:-}" ] && [ -n "${ASSETS_S3_BUCKET_PATH:-}" ]; then
    as_code_owner "$(escape_shell_args "aws" "s3" "sync" "--exclude=${ASSETS_S3_EXCLUDE_PATTERN}" "${ASSETS_S3_BUCKET_PATH}" "${ASSETS_PATH}")"
  else
    echo 'Skipping assets download due to ASSETS_PATH and/or ASSETS_S3_BUCKET_PATH not being set'
  fi
}

function do_assets_cleanup()
{
  if [ -n "${ASSETS_PATH:-}" ]; then
    rm -rf "${ASSETS_PATH}"
  fi
}

function do_assets_apply()
{
  if [ -n "${ASSETS_PATH:-}" ]; then
    do_assets_apply_database
    do_assets_apply_files

    if [ "${ASSETS_CLEANUP}" == "true" ]; then
      do_assets_cleanup
    fi
  else
    echo 'Skipping assets apply due to ASSETS_PATH not being set'
  fi
}

function do_assets_all()
{
  do_assets_download
  do_assets_apply
}

function assets_list()
{
  local -r ASSETS_PATTERN="$1"
  if [ -z "${ASSETS_PATH:-}" ];then
    return 0
  fi

  for ASSET_FILE in "${ASSETS_PATH}"/*; do
    if [[ $ASSET_FILE =~ $ASSETS_PATTERN ]]; then
      echo "${ASSET_FILE}"
    fi
  done;
}

function assets_apply_database()
{
  set +x
  local DECOMPRESS
  local -r ASSET_FILE="$1"
  local -r APPLY_DATABASE_NAME="$2"
  local -r APPLY_FORCE_DATABASE_DROP="$(convert_to_boolean_string "${3:-0}")"

  case "${ASSET_FILE}" in
  *.sql.gz)
    DECOMPRESS=(gunzip -c "${ASSET_FILE}")
    ;;
  *.sql.bz2)
    DECOMPRESS=(bunzip2 -c "${ASSET_FILE}")
    ;;
  *.sql)
    DECOMPRESS=(cat "${ASSET_FILE}")
    ;;
  *)
    echo "Unknown database dump format for ${ASSET_FILE}, supported *.sql, *.sql.gz, *.sql.bz2"
    return 1
  esac

  local DATABASE_ARGS=(-h"${DATABASE_HOST}")

  if [ -n "${DATABASE_ADMIN_USER}" ]; then
    DATABASE_ARGS+=(-u"${DATABASE_ADMIN_USER}" -p"${DATABASE_ADMIN_PASSWORD}")
  else
    DATABASE_ARGS+=(-u"${DATABASE_USER}" -p"${DATABASE_PASSWORD}")
  fi

  local DATABASES
  mapfile -t DATABASES < <(mysql "${DATABASE_ARGS[@]}" --execute="SHOW DATABASES" | tail --lines=+2)

  set +e
  ! printf "%s\n" "${DATABASES[@]}" | grep --quiet --fixed-strings --line-regexp "${APPLY_DATABASE_NAME}"
  local DATABASE_EXISTS=$?
  set -e

  local DATABASE_TABLES=()
  if [ "${DATABASE_EXISTS}" -ne 0 ]; then
    mapfile -t DATABASE_TABLES < <(mysql "${DATABASE_ARGS[@]}" "${APPLY_DATABASE_NAME}" -e "SHOW TABLES" | tail --lines=+2)
  fi
  

  if [ "${DATABASE_EXISTS}" -ne 0 ] && [ "${APPLY_FORCE_DATABASE_DROP}" == 'true' ]; then
    echo "Dropping the ${APPLY_DATABASE_NAME} MySql database"
    mysql "${DATABASE_ARGS[@]}" --execute="DROP DATABASE \`${APPLY_DATABASE_NAME}\`"
    DATABASE_EXISTS=0
    DATABASE_TABLES=()
  fi

  if [ "$DATABASE_EXISTS" -eq 0 ]; then
    echo "Creating ${APPLY_DATABASE_NAME} MySql database"
    echo "CREATE DATABASE \`${APPLY_DATABASE_NAME}\`" | mysql "${DATABASE_ARGS[@]}"
  fi

  if [ "${#DATABASE_TABLES[@]}" -eq 0 ]; then
    echo "Importing ${ASSET_FILE} into ${APPLY_DATABASE_NAME} MySql database"
    "${DECOMPRESS[@]}" | mysql "${DATABASE_ARGS[@]}" "${APPLY_DATABASE_NAME}"
  fi
  set -x
}

function do_assets_apply_database()
{
  if [ "$ASSETS_DATABASE_ENABLED" == "false" ]; then
     return 0
  fi

  local ASSET_FILES
  mapfile -t ASSET_FILES < <(assets_list "$ASSETS_DATABASE_PATTERN")
  local -r CAPTURE_GROUP="${ASSETS_DATABASE_NAME_CAPTURE_GROUP}"
  for ASSET_FILE in "${ASSET_FILES[@]}"; do
    local APPLY_DATABASE_NAME="${DATABASE_NAME}"

    if [[ $ASSET_FILE =~ $ASSETS_DATABASE_PATTERN ]]; then
      if [ "${CAPTURE_GROUP}" -gt 0 ] && [ "${#BASH_REMATCH[@]}" -gt "${CAPTURE_GROUP}" ]; then
        APPLY_DATABASE_NAME="${BASH_REMATCH[${CAPTURE_GROUP}]}"
      fi
    else
      continue
    fi

    assets_apply_database "${ASSET_FILE}" "${APPLY_DATABASE_NAME}" "${FORCE_DATABASE_DROP}"
  done
}

function do_assets_apply_files()
{
  if [ "$ASSETS_FILES_ENABLED" == "false" ]; then
     return 0
  fi

  local ASSET_FILES
  mapfile -t ASSET_FILES < <(assets_list "$ASSETS_FILES_PATTERN")
  for ASSET_FILE in "${ASSET_FILES[@]}"; do
    as_code_owner "$(escape_shell_args "tar" "--extract" "--no-same-owner" "--touch" "--overwrite" "--file" "${ASSET_FILE}")"
  done

  do_assets_apply_file_permissions
}

function do_assets_apply_file_permissions()
{
  :
}
