#!/bin/bash
set -Eeuo pipefail

if [ -n "${MONGODB_ADMIN_USER:-}" ]; then
    export MONGO_INITDB_ROOT_USERNAME=${MONGO_INITDB_ROOT_USERNAME:-$MONGODB_ADMIN_USER}
    echo 'MONGODB_ADMIN_USER environment variable is deprecated, please use MONGO_INITDB_ROOT_USERNAME instead' >&2
fi

if [ -n "${MONGODB_ADMIN_USER:-}" ]; then
    export MONGO_INITDB_ROOT_PASSWORD=${MONGO_INITDB_ROOT_PASSWORD:-$MONGODB_ADMIN_PWD}
    echo 'MONGODB_ADMIN_PWD environment variable is deprecated, please use MONGO_INITDB_ROOT_PASSWORD instead' >&2
fi

if [ "${MONGODB_AUTH_ENABLED:-}" -eq 1 ] && [ -z "${MONGO_INITDB_ROOT_USERNAME:-}" ] && [ -z "${MONGO_INITDB_ROOT_PASSWORD:-}" ]; then
    export MONGO_INITDB_ROOT_USERNAME=admin
    MONGO_INITDB_ROOT_PASSWORD=$(set +o pipefail && tr -dc 'a-zA-Z0-9' < /dev/urandom | fold -w 32 | head -n 1)
    export MONGO_INITDB_ROOT_PASSWORD
fi

exec bash docker-entrypoint.sh "$@"
