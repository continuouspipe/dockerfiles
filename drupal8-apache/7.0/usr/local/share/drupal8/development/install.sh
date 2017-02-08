#!/bin/bash
set -xe

# Ensure confd can create the hem config in the build user's home directory
mkdir -p /home/build/.hem/gems/ && chown -R build:build /home/build/.hem/

# Ensure the hem and drupal settings files exists by running confd before continuing
source /usr/local/share/bootstrap/setup.sh
source /usr/local/share/bootstrap/run_confd.sh

# install DB and assets
if [ -L "$0" ] ; then
    DIR="$(dirname "$(readlink -f "$0")")" ;
else
    DIR="$(dirname "$0")" ;
fi ;

# Install composer and npm dependencies
bash "$DIR/../install.sh";
bash "$DIR/../install_finalise.sh";

source /usr/local/share/bootstrap/common_functions.sh

# Install database
export DATABASE_NAME=drupaldb
export DATABASE_USER=drupal
export DATABASE_PASSWORD=drupal
export DATABASE_ROOT_PASSWORD=drupal
export DATABASE_HOST=database

bash "$DIR/install_database.sh"

# Default Docker public address
if [ -z "$PUBLIC_ADDRESS" ]; then
    export PUBLIC_ADDRESS=http://drupal_docker.docker/
fi

bash "$DIR/install_assets.sh"

as_code_owner "drush cache-rebuild" "/app/docroot"

if [ -f "$DIR/install_custom.sh" ]; then
  bash "$DIR/install_custom.sh"
fi
