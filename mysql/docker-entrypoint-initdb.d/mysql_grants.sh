#!/bin/bash

if [ "$MYSQL_USER" ] && [ "$MYSQL_PASSWORD" ]; then
    if [ "$MYSQL_DATABASE_GRANT" ]; then
        # shellcheck disable=SC2154
        echo "GRANT ALL ON \`$MYSQL_DATABASE_GRANT\`.* TO '$MYSQL_USER'@'%' ;" | "${mysql[@]}"
    fi
fi
