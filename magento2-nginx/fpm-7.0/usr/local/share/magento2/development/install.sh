#!/bin/sh
set -xe

# install DB and assets
if [ -L "$0" ] ; then
    DIR="$(dirname "$(readlink -f "$0")")" ;
else
    DIR="$(dirname "$0")" ;
fi ;

# Install composer and npm dependencies
sh "$DIR/../install_magento.sh";

# Default Docker public address
if [ -z "$PUBLIC_ADDRESS" ]; then
    export PUBLIC_ADDRESS=http://magento_web.docker/
fi

set -ex

# Run HEM
export HEM_RUN_ENV="${HEM_RUN_ENV:-local}"
hem --non-interactive --skip-host-checks assets download

# Install assets
export DATABASE_NAME=magentodb
export DATABASE_USER=magento
export DATABASE_PASSWORD=magento
export DATABASE_ROOT_PASSWORD=magento
export DATABASE_HOST=database

sh "$DIR/install_database.sh"

echo "DELETE from core_config_data WHERE path LIKE 'web/%base_url';
INSERT INTO core_config_data VALUES (NULL, 'default', '0', 'web/unsecure/base_url', '$PUBLIC_ADDRESS');
INSERT INTO core_config_data VALUES (NULL, 'default', '0', 'web/secure/base_url', '$PUBLIC_ADDRESS');" |  mysql -h$DATABASE_HOST -u$DATABASE_USER -p$DATABASE_PASSWORD $DATABASE_NAME || exit 1

sh "$DIR/install_assets.sh"

