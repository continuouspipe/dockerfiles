#!/bin/sh

set -xe

source ./common_functions.sh

bin/magento setup:upgrade

# Compile the DIC if to be productionized
if [ "$PRODUCTION_ENVIRONMENT" = "1" ]; then
  bin/magento setup:di:compile
fi

(bin/magento indexer:reindex || echo "Failing indexing to the end, ignoring.") && echo "Indexing successful"

# Download and install the assets when running the image
# (sad that we have to do that tho...)
if [ -L "$0" ] ; then
    DIR="$(dirname "$(readlink -f "$0")")" ;
else
    DIR="$(dirname "$0")" ;
fi ;

# Download the static assets
export HEM_RUN_ENV="${HEM_RUN_ENV:-local}"
hem --non-interactive --skip-host-checks assets download
sh "$DIR/development/install_assets.sh"

# Update users
# /app/tools/docker/update-users.sh

# Ensure the permissions or for `www-data`
chown -R www-data:www-data pub var auth.json

# Flush magento cache
cd /app
bin/magento cache:flush
