#!/bin/bash
#
# This file creates a user to match the UID & GID
# of the file sent as an argument.
#
# Usage:
# $ update-permissions.sh /app/file-or-folder
#

randname() {
    local -x LC_ALL=C
    tr -dc '[:lower:]' < /dev/urandom |
        dd count=1 bs=16 2>/dev/null
}

function update_permissions() {
    REFERENCE="$1"
    read -r owner group owner_id group_id < <(stat -c '%U %G %u %g' "$REFERENCE")
    if [[ "$owner" = UNKNOWN ]]; then
        APP_USER="build"
        if [ "$APP_USER_LOCAL_RANDOM" == 'true' ]; then
            APP_USER="$(randname)"
        fi
        CODE_OWNER="$APP_USER"
        export APP_USER
        export CODE_OWNER
        if [[ "$group" = UNKNOWN ]]; then
            APP_GROUP="$APP_USER"
            CODE_GROUP="$APP_GROUP"
            export APP_GROUP
            export CODE_GROUP
            groupadd --system --gid "$group_id" "$APP_GROUP" || groupmod -g "$group_id" "$APP_GROUP"
        else
            APP_GROUP="$group"
            CODE_GROUP="$APP_GROUP"
            export APP_GROUP
            export CODE_GROUP
        fi
        useradd --create-home --system --uid "$owner_id" --gid "$group_id" "$APP_USER" || usermod -u "$owner_id" -g "$APP_GROUP" "$APP_USER"

        # Adjust any templates that are meant to be written out as UID 999 (assumed to be build)
        # to be written out as the new owner_id instead
        find /etc/confd/conf.d/ -type f -exec sed -i -E "s/uid\s*=\s*999/uid=$owner_id/g" {} \;
    else
        echo "The user $owner with ID $owner_id already exists in the container. Nothing to do."
    fi
}
