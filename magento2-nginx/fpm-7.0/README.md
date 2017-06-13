# Magento 2 NGINX/PHP-FPM

In a Dockerfile:
```Dockerfile
FROM quay.io/continuouspipe/magento2-nginx-php7:stable

ARG GITHUB_TOKEN=
ARG MAGENTO_USERNAME=
ARG MAGENTO_PASSWORD=

COPY . /app
RUN container build
```

## How to build
```bash
docker-compose build magento2_nginx
docker-compose push magento2_nginx
```

## About

This is a Docker image that can install and serve a Magento 2 installation via NGINX and PHP 7.

## How to use

As for all images based on the ubuntu base image, see
[the base image README](../../ubuntu/16.04/README.md)

Before starting services, on boot the container will call the following scripts:

1. `bash /usr/local/share/magento2/install_magento.sh`, which is shared by the Dockerfile build, and should not contain
   references to external services such as databases which will not be present when built.
2. `bash /usr/local/share/magento2/install_magento_finalise.sh` which can contain calls to databases, redis, etc.

### Custom build and startup scripts

To run commands during the build and startup sequences that the base images add,
please add `usr/local/share/container/plan.sh` for a project, or
`usr/local/share/container/baseimage-{number}.sh` if creating another base image.

This allows you to define and override bash functions that the base images add.

In addition to the bash functions defined in this base image's parent images:
* [the base image functions](../../ubuntu/16.04/README.md#custom-build-and-startup-scripts)
* [the php-nginx image functions](../../php-nginx/README.md#custom-build-and-startup-scripts)

This base image adds the following bash functions:

function | description | executed on
--- | --- | ---
do_magento2_install | Builds Magento | do_build
do_magento2_development_start | Installs Magento | do_development_start

These functions can be triggered via the /usr/local/bin/container command, dropping off the "do_" part. e.g:

/usr/local/bin/container build # runs do_build
/usr/local/bin/container start_supervisord # runs do_start_supervisord

#### Environment variables

The following variables are supported

Variable | Description | Expected values | Default
--- | --- | --- | ----
PHP_MEMORY_LIMIT | PHP memory limit | - | 768M
PRODUCTION_ENVIRONMENT | If true, magento DI will be compiled | true/false | false
APP_HOSTNAME | Web server's host name | \<projectname\>.docker | magento.docker
PUBLIC_ADDRESS | Magento base URL. Note that an underscore should not be used due to magento admin login using PHP's filter_var to check for domain validity. "_" is not a valid character in a domain name. |  https://\<projectname\>.docker/ | https://magento.docker/
FORCE_DATABASE_DROP | Drops the existing database before importing from assets | true/false | false
DATABASE_ARCHIVE_PATH | Database dump's archive path | relative path | tools/assets/development/magentodb.sql.gz
DATABASE_NAME | Magento database name | - | magentodb
DATABASE_USER | Magento database user | - | magento
DATABASE_PASSWORD | Magento database password | - | magento
DATABASE_ADMIN_USER | Optional MySQL database password to perform DBA operations, DATABASE_USER will be used if not specified | - | -
DATABASE_ADMIN_PASSWORD | Optional MySQL database password to perform DBA operations, DATABASE_PASSWORD will be used if not specified | - | -
DATABASE_HOST | Magento database host | - | database
ADDITIONAL_SETUP_SQL | Any additional SQL query which should be executed after database import (changing base URLs and setting varnish host/port is added by default) | SQL Query | - 
ASSET_ARCHIVE_PATH | Asset files archive path | relative path | tools/assets/development/media.files.tgz 
ASSET_DOWNLOAD_ENVIRONMENTS | Assets will be downloaded for this environment name | - | development
FRONTEND_INSTALL_DIRECTORY | NPM modules will be installed within this directory (if it exists) | absolute path (normally we mount the source at /app) | /app/tools/inviqa
FRONTEND_BUILD_DIRECTORY | Gulp command will be executed within this directory (if it exists) | absolute path (normally we mount the source at /app) | /app/tools/inviqa
FRONTEND_BUILD_ACTION | Gulp command to run | gulp command name | build
GULP_BUILD_THEME_NAME | If specified, will be passed to gulp command as "--theme=<theme name>" | - | - 
MAGENTO_MODE | Used to set Magento mode. If set to "production", static content will be deployed | default/developer/production | production
MAGENTO_RUN_CODE_MAPPING | Mapped to http_host and default store name. First part of the value is the host name and second part is magento's store code (separated by space). Don't forget to add ";" at the end. | - | magento_web.docker default; 
MAGENTO_RUN_TYPE | Used to set Magento store type. | store/website | store
FRONTEND_COMPILE_LANGUAGES | Used during static content deployment. It can be multiple language codes. | language code(s) separated by space | en_GB
MAGENTO_DEPENDENCY_INJECTION_COMPILE_COMMAND | Magento DI compile command | - | bin/magento setup:di:compile 
MAGENTO_CRYPT_KEY | Magneto crypt key | - | -
COMPOSER_CUSTOM_CONFIG_COMMAND | Used to set any custom composer configuration, will be executed before composer install | composer config .. | -
REDIS_HOST | Redis host name (to store cache and sessions) | - | redis 
REDIS_HOST_PORT | Redis port | port number | 6379
MAGENTO_ENABLE_CACHE | Should redis be used for cache? | true/false | true
MAGENTO_USE_REDIS | Should redis be used for sessions? | true/false | true
REDIS_USE_SENTINEL | If you are running a redis cluster watched by sentinels and have Cm_Cache_Redis_Backend v1.10.x, set this to true to avoid trying to write to the redis followers | boolean | true/false
REDIS_SENTINEL_HOSTS | Comma seperated list of sentinel protocol/host/ports to talk to to find out which redis server is the leader | CSV of protocol/hostname/ports | tcp://redis-sentinel-0.redis-sentinel-headless:26379,tcp://redis-sentinel-1.redis-sentinel-headless:26379,tcp://redis-sentinel-2.redis-sentinel-headless:26379
REDIS_SENTINEL_MASTER | The name of the leader to ask the redis sentinels regarding. | string | mymaster
REDIS_SENTINEL_SERVICE_HOST | The hostname of the redis sentinel service. Used whilst magento_clear_redis_cache() function runs | hostname | redis-sentinel-headless
REDIS_SENTINEL_SERVICE_PORT | The port of the redis sentinel service. Used whilst magento_clear_redis_cache() function runs | 1-65535 | 26379
MAGENTO_REDIS_CACHE_DATABASE | Redis database number to store block cache | database number | 0
MAGENTO_REDIS_FULL_PAGE_CACHE_DATABASE | Redis database number to store full page cache | database number | 1
MAGENTO_REDIS_SESSION_DATABASE | Redis database number to store sessions | database number | 2
MAGENTO_ADMIN_FRONTNAME | Magento backend frontname | - | admin
MAGENTO_ADMIN_FRONTNAME_REGEX_ESCAPED | The admin URL "front name" that is configured for the magento application. Please escape any regular expression special characters. | regex escaped string | value of MAGENTO_ADMIN_FRONTNAME
MAGENTO_PROTECT_ADMIN | Should IP whitelisting/Basic Auth be deployed for the MAGENTO_ADMIN_FRONTNAME_REGEX_ESCAPED path? | true/false | false
MAGENTO_ADMIN_HTPASSWD | The htpasswd format `username:hashed_password` to protect admin with. Leave blank to just use IP Whitelisting. | htpasswd format username/passwords | empty
MAGENTO_ADMIN_IP_WHITELIST | The comma separated list of whitelisted IP addresses that can visit the admin path. Leave blank to just use htpasswd | CSV of IP addresses | Value of $AUTH_IP_WHITELIST, which may be blank or "127.0.0.1/32, ::1, 10.0.0.0/14"
START_MODE | Start in "web" mode to serve a site, or "cron" mode to run the cron | (web|cron) | web
MAGENTO_HTTP_CACHE_HOSTS | Comma separated list of upstream HTTP cache hosts (for example, varnish) that magento will PURGE when clearing full page cache | CSV of hostnames/IPs | empty
MAGENTO_HTTP_CACHE_PORT | Port to talk to on the upstream HTTP cache hosts | 1-65535 | 80
MAGENTO_ALLOW_ACCESS_TO_SETUP | Whether to allow access to the /setup URL or not | true/false | true
MAGENTO_ALLOW_ACCESS_TO_UPDATE | Whether to allow access to the /update URL or not | true/false | true
