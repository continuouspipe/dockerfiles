#!/bin/bash

if [ "${APP_USER_LOCAL}" == "true" ]; then
  source /usr/local/share/bootstrap/update_permissions.sh
  update_permissions "${WORK_DIRECTORY}"
fi
