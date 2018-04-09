#!/bin/bash
set -Eeuo pipefail

file_env "MONGODB_USERS" "[]"

printf "%s" "$MONGODB_USERS" > "/tmp/users.json"

# shellcheck disable=SC2154
"${mongo[@]}" "$MONGO_INITDB_DATABASE" "/docker-entrypoint-initdb.d/mongo-set-auth/auth.js"

rm "/tmp/users.json"

echo
