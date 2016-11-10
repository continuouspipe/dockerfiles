#!/bin/bash
set -xe

# install DB and assets
if [ -L "$0" ] ; then
    DIR="$(dirname "$(readlink -f "$0")")" ;
else
    DIR="$(dirname "$0")" ;
fi ;

# shellcheck source=../common_functions.sh
source "$DIR/../common_functions.sh";

# Install database
export DATABASE_NAME=drupaldb
export DATABASE_USER=drupal
export DATABASE_PASSWORD=drupal
export DATABASE_ROOT_PASSWORD=drupal
export DATABASE_HOST=database

sh "$DIR/install_database.sh"

# Install composer and npm dependencies
bash "$DIR/../install.sh";

# Default Docker public address
if [ -z "$PUBLIC_ADDRESS" ]; then
    export PUBLIC_ADDRESS=http://drupal_docker.docker/
fi

set +e
is_hem_project
IS_HEM=$?
set -e
if [ "$IS_HEM" -eq 0 ]; then
  # Run HEM
  export HEM_RUN_ENV="${HEM_RUN_ENV:-local}"
  as_build "hem --non-interactive --skip-host-checks assets download"
fi

# Install assets
sh "$DIR/install_assets.sh"

if [ -f "$DIR/install_custom.sh" ]; then
  bash "$DIR/install_custom.sh"
fi
