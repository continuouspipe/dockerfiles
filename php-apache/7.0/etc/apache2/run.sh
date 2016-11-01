#!/bin/bash

set -xe

# Configure the basic authentication if needed
if [ ! -z "$HTTP_BASIC_USERNAME" ] && [ "$HTTP_BASIC_DISABLED" != "1" ]; then
	htpasswd -cb /etc/apache2/users $HTTP_BASIC_USERNAME $HTTP_BASIC_PASSWORD
	sed -i 's/#AUTH: / /g' /etc/apache2/sites-available/000-default.conf
fi

# Configure the basic authentication if needed
if [ "$SYMFONY_ENV" = "prod" ]; then
	sed -i 's/#PROD: / /g' /etc/apache2/sites-available/000-default.conf
fi

# Configure Tideways' API
if [ -n "$TIDEWAYS_API_KEY" ]; then
    echo "tideways.api_key = $TIDEWAYS_API_KEY" >> /etc/php/7.0/mods-available/tideways.ini
    echo "tideways.connection = tcp://tideways:9135" >> /etc/php/7.0/mods-available/tideways.ini
fi

#if [ -f .using-user-permissions ]; then
#    ./update-permissions.sh
#fi

exec apache2 -DFOREGROUND
