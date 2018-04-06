#!/bin/bash

set -e

MONGODB_AUTH_ENABLED=${MONGODB_AUTH_ENABLED:-0}
MONGODB_BIND_IP=${MONGODB_BIND_IP:-0.0.0.0}

if [ -n "$MONGODB_ADMIN_USER" ] || [ -n "$MONGODB_USERS" ]; then
    mongod --bind_ip 127.0.0.1 &
    MONGO_PID=$!

    pushd /usr/local/share/mongodb
        # script to wait for server to be started
        mongo --nodb mongo-startup.js

        echo 'var env = {};' > env.js
        export | sed -e 's/declare -x /env./;' | grep '^env.MONGODB' >> env.js

        mongo mongo-set-auth.js

        rm env.js
    popd

    kill "${MONGO_PID}"
    flock /data/db/mongod.lock true
fi

if [ "$MONGODB_AUTH_ENABLED" -eq 1 ]; then
    exec mongod --auth --bind_ip "$MONGODB_BIND_IP"
else
    exec mongod --bind_ip "$MONGODB_BIND_IP"
fi
