#!/bin/bash

mysql_database_admin_args()
(
  set +x
  local PASSED_DATABASE_NAME="${1:-$DATABASE_NAME}"
  local DATABASE_ARGS=("--host=${DATABASE_HOST}" "--port=${DATABASE_PORT}")

  if [ -n "${DATABASE_ADMIN_USER}" ]; then
    DATABASE_ARGS+=("--user=${DATABASE_ADMIN_USER}" "--password=${DATABASE_ADMIN_PASSWORD}")
  else
    DATABASE_ARGS+=("--user=${DATABASE_USER}" "--password=${DATABASE_PASSWORD}")
  fi

  if [ -n "${PASSED_DATABASE_NAME}" ]; then
    DATABASE_ARGS+=("${PASSED_DATABASE_NAME}")
  fi

  echo "${DATABASE_ARGS[@]}"
)

postgres_database_admin_args()
(
  set +x
  local PASSED_DATABASE_NAME="${1:-$DATABASE_NAME}"
  local DATABASE_ARGS=("--host=${DATABASE_HOST}" "--port=${DATABASE_PORT}")

  if [ -n "${DATABASE_ADMIN_USER}" ]; then
    DATABASE_ARGS+=("--username=${DATABASE_ADMIN_USER}")
  else
    DATABASE_ARGS+=("--username=${DATABASE_USER}")
  fi

  if [ -n "${PASSED_DATABASE_NAME}" ]; then
    DATABASE_ARGS+=("${PASSED_DATABASE_NAME}")
  fi

  echo "${DATABASE_ARGS[@]}"
)

postgres_database_admin_password()
(
  set +x
  if [ -n "${DATABASE_ADMIN_USER}" ]; then
    echo "${DATABASE_ADMIN_PASSWORD}"
  else
    echo "${DATABASE_PASSWORD}"
  fi
)

mysql_database_exists()
{
  set +x
  local CHECK_DATABASE_NAME="$1"
  local DATABASE_ARGS
  DATABASE_ARGS="$(mysql_database_admin_args)"

  wait_for_remote_ports "${ASSETS_DATABASE_WAIT_TIMEOUT}" "${DATABASE_HOST}:${DATABASE_PORT}"

  local DATABASES
  DATABASES="$(set -o pipefail && mysql ${DATABASE_ARGS[*]} --execute="SHOW DATABASES" | tail --lines=+2)"
  if [ "$?" -ne 0 ]; then
    echo "Failed to check if the database '${CHECK_DATABASE_NAME}' exists, exiting."
    exit 1
  fi

  set +e
  echo "${DATABASES}" | grep --quiet --fixed-strings --line-regexp "${CHECK_DATABASE_NAME}"
  local DATABASE_EXISTS="$?"

  set -ex
  return "$DATABASE_EXISTS"
}

postgres_database_exists()
{
  set +x
  local CHECK_DATABASE_NAME="$1"
  local DATABASE_ARGS
  IFS=" " read -r -a DATABASE_ARGS <<< "$(postgres_database_admin_args "${CHECK_DATABASE_NAME}")"
  local PGPASSWORD
  PGPASSWORD="$(postgres_database_admin_password)"

  wait_for_remote_ports "${ASSETS_DATABASE_WAIT_TIMEOUT}" "${DATABASE_HOST}:${DATABASE_PORT}"

  local DATABASES
  DATABASES="$(set -o pipefail && PGPASSWORD="${PGPASSWORD}" psql "${DATABASE_ARGS[@]}" -lqt | cut -d \| -f 1 | sed "s/ //g")"
  # shellcheck disable=SC2181
  if [ "$?" -ne 0 ]; then
    echo "Failed to check if the database '${CHECK_DATABASE_NAME}' exists, exiting."
    exit 1
  fi

  set +e
  echo "${DATABASES}" | grep --quiet --fixed-strings --line-regexp "${CHECK_DATABASE_NAME}"
  local DATABASE_EXISTS="$?"

  set -ex
  return "$DATABASE_EXISTS"
}

create_mysql_database()
(
  set +x
  local CREATE_DATABASE_NAME="$1"

  local DATABASE_ARGS
  DATABASE_ARGS="$(mysql_database_admin_args)"

  echo "Creating ${CREATE_DATABASE_NAME} MySQL database"
  echo "CREATE DATABASE \`${CREATE_DATABASE_NAME}\`" | mysql ${DATABASE_ARGS[*]}
)

create_postgres_database()
(
  set +x
  local CREATE_DATABASE_NAME="$1"

  local DATABASE_ARGS
  IFS=" " read -r -a DATABASE_ARGS <<< "$(postgres_database_admin_args)"
  local PGPASSWORD
  PGPASSWORD="$(postgres_database_admin_password)"

  echo "Creating ${CREATE_DATABASE_NAME} Postgres database"
  PGPASSWORD="${PGPASSWORD}" createdb "${DATABASE_ARGS[@]}" "${CREATE_DATABASE_NAME}"
)

drop_mysql_database()
(
  set +x
  local DROP_DATABASE_NAME="$1"

  local DATABASE_ARGS
  DATABASE_ARGS="$(mysql_database_admin_args)"

  echo "Dropping the ${DROP_DATABASE_NAME} MySQL database"
  mysql ${DATABASE_ARGS[*]} --execute="DROP DATABASE \`${DROP_DATABASE_NAME}\`"
)

drop_postgres_database()
(
  set +x
  local DROP_DATABASE_NAME="$1"

  local DATABASE_ARGS
  DATABASE_ARGS="$(postgres_database_admin_args "${CREATE_DATABASE_NAME}")"
  local PGPASSWORD
  PGPASSWORD="$(postgres_database_admin_password)"

  echo "Dropping the ${DROP_DATABASE_NAME} Postgres database"
  PGPASSWORD="$PGPASSWORD" psql ${DATABASE_ARGS[*]} --command='DROP SCHEMA public CASCADE;' "${DROP_DATABASE_NAME}"
)

mysql_list_tables()
{
  set +x
  local LIST_DATABASE_NAME="${1:-$DATABASE_NAME}"

  local DATABASE_ARGS
  DATABASE_ARGS="$(mysql_database_admin_args "${LIST_DATABASE_NAME}")"

  wait_for_remote_ports "${ASSETS_DATABASE_WAIT_TIMEOUT}" "${DATABASE_HOST}:${DATABASE_PORT}"

  mysql_database_exists "${LIST_DATABASE_NAME}"
  set +x

  local DATABASE_TABLES=""
  DATABASE_TABLES="$(set -o pipefail && mysql ${DATABASE_ARGS[*]} "${LIST_DATABASE_NAME}" -e "SHOW TABLES" | tail --lines=+2)"
  if [ "$?" -ne 0 ]; then
    echo "Failed to get a list of tables from '${LIST_DATABASE_NAME}', exiting."
    exit 1
  fi

  echo "$DATABASE_TABLES"
  set -x
}

postgres_list_tables()
{
  set +x
  local LIST_DATABASE_NAME="${1:-$DATABASE_NAME}"

  local DATABASE_ARGS
  IFS=" " read -r -a DATABASE_ARGS <<< "$(postgres_database_admin_args "${LIST_DATABASE_NAME}")"
  local PGPASSWORD
  PGPASSWORD="$(postgres_database_admin_password)"

  wait_for_remote_ports "${ASSETS_DATABASE_WAIT_TIMEOUT}" "${DATABASE_HOST}:${DATABASE_PORT}"

  postgres_database_exists "${LIST_DATABASE_NAME}"
  set +x

  local DATABASE_TABLES=""
  local DATABASE_TABLE_COUNT=0

  DATABASE_TABLES="$(set -o pipefail && PGPASSWORD="${PGPASSWORD}" psql "${DATABASE_ARGS[@]}" -c '\dt' -qt "${LIST_DATABASE_NAME}" | cut -d \| -f 2 | sed "s/ //g")"
  # shellcheck disable=SC2181
  if [ "$?" -ne 0 ]; then
    echo "Failed to get a list of tables from '${LIST_DATABASE_NAME}', exiting."
    exit 1
  fi
  DATABASE_TABLE_COUNT="$(echo "${DATABASE_TABLES}" | wc -l)"

  # an empty database contains a empty line, so treat that as empty
  if [ "${DATABASE_TABLE_COUNT}" -eq 1 ] && [ "${DATABASE_TABLES}" == "\\n" ]; then
    DATABASE_TABLES=""
    DATABASE_TABLE_COUNT=0
  fi
  echo "$DATABASE_TABLES"
  set -x
}

mysql_has_table()
{
  set +x
  local TABLE_NAME="$1"

  local DATABASE_TABLES
  DATABASE_TABLES="$(mysql_list_tables "${DATABASE_NAME}")"
  if [ "$?" -ne 0 ]; then
    exit 1
  fi

  set +ex
  echo "${DATABASE_TABLES}" | grep --quiet --fixed-strings --line-regexp "${TABLE_NAME}"
  local TABLE_EXISTS="$?"
  set -ex
  return "$TABLE_EXISTS"
}

postgres_has_table()
{
  set +x
  local TABLE_NAME="$1"

  local DATABASE_TABLES
  DATABASE_TABLES="$(postgres_list_tables "${DATABASE_NAME}")"
  # shellcheck disable=SC2181
  if [ "$?" -ne 0 ]; then
    exit 1
  fi

  set +ex
  echo "${DATABASE_TABLES}" | grep --quiet --fixed-strings --line-regexp "${TABLE_NAME}"
  local TABLE_EXISTS="$?"
  set -ex
  return "$TABLE_EXISTS"
}
