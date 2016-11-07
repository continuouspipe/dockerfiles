#!/bin/sh

set -xe

if [ -L "$0" ] ; then
    DIR="$(dirname "$(readlink -f "$0")")" ;
else
    DIR="$(dirname "$0")" ;
fi ;

source "$DIR/common_functions.sh"
bin/magento setup:upgrade

# Compile the DIC if to be productionized
if [ "$PRODUCTION_ENVIRONMENT" = "1" ]; then
  bin/magento setup:di:compile
fi

(bin/magento indexer:reindex || echo "Failing indexing to the end, ignoring.") && echo "Indexing successful"

# Download and install the assets when running the image
# (sad that we have to do that tho...)

# Download the static assets
$(is_hem_project)
IS_HEM=$?
if [ "$IS_HEM" -eq 0 ]; then
  export HEM_RUN_ENV="${HEM_RUN_ENV:-local}"
  as_build "hem --non-interactive --skip-host-checks assets download"
  sh "$DIR/development/install_assets.sh"
fi

# Update users
# /app/tools/docker/update-users.sh

# Ensure the permissions or for `www-data`
chown -R www-data:www-data pub var auth.json

# Flush magento cache
cd /app
bin/magento cache:flush
