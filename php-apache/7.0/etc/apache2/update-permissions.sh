#!/bin/bash
#
# This file updates the Apache user and group to match the UID & GID
# of the file sent as an argument.
#
# Usage:
# $ update-permissions.sh /app/file-or-folder
#

REFERENCE=$1

randname() {
    local -x LC_ALL=C
    tr -dc '[:lower:]' < /dev/urandom |
        dd count=1 bs=16 2>/dev/null
}

read owner group owner_id group_id < <(stat -c '%U %G %u %g' $REFERENCE)
if [[ $owner = UNKNOWN ]]; then
    owner=$(randname)
    if [[ $group = UNKNOWN ]]; then
        group=$owner
        addgroup --system --gid "$group_id" "$group"
    fi
    adduser --system --uid=$owner_id --gid=$group_id "$owner"
fi

# Update the Apache2 users
sed -i 's/User www-data/User '$owner'/' /etc/apache2/apache2.conf
sed -i 's/Group www-data/Group '$group'/' /etc/apache2/apache2.conf
