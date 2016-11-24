#!/bin/bash

set -ex

if [ -L "$0" ] ; then
    DIR="$(dirname "$(readlink -f "$0")")" ;
else
    DIR="$(dirname "$0")" ;
fi

command -v shellcheck >/dev/null 2>&1 || { echo >&2 "I require shellcheck but it's not installed. Aborting."; exit 1; }
command -v hadolint >/dev/null 2>&1 || { echo >&2 "I require hadolint but it's not installed. Aborting."; exit 1; }

find "$DIR" -type f \( -name "*.sh" -or -name "*_env_variables" -or -name "supervisor*_start" \) -exec shellcheck --exclude SC1091 {} +
find "$DIR" -type f -name "Dockerfile" -exec hadolint --ignore DL3008 --ignore DL3002 {} \;
