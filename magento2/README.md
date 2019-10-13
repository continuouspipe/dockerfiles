# Magento 2 NGINX/PHP-FPM

In a Dockerfile for PHP 7.3, with 10.x LTS version of NodeJS:
```Dockerfile
FROM quay.io/continuouspipe/magento2-nginx-php7.3-ng:latest

ARG GITHUB_TOKEN=
ARG MAGENTO_USERNAME=
ARG MAGENTO_PASSWORD=
ARG IMAGE_VERSION=3

COPY . /app
RUN container build
```

In a Dockerfile for PHP 7.2, with 10.x LTS version of NodeJS:
```Dockerfile
FROM quay.io/continuouspipe/magento2-nginx-php7.2-ng:latest

ARG GITHUB_TOKEN=
ARG MAGENTO_USERNAME=
ARG MAGENTO_PASSWORD=
ARG IMAGE_VERSION=3

COPY . /app
RUN container build
```

In a Dockerfile for PHP 7.1 without Hem and 6.x version of NodeJS:
```Dockerfile
FROM quay.io/continuouspipe/magento2-nginx-php7.1-ng:latest

ARG GITHUB_TOKEN=
ARG MAGENTO_USERNAME=
ARG MAGENTO_PASSWORD=
ARG IMAGE_VERSION=3

COPY . /app
RUN container build
```

In a Dockerfile for PHP 7.1 with Hem and 6.x version of NodeJS:
```Dockerfile
FROM quay.io/continuouspipe/magento2-nginx-php7.1:latest

ARG GITHUB_TOKEN=
ARG MAGENTO_USERNAME=
ARG MAGENTO_PASSWORD=
ARG IMAGE_VERSION=3

COPY . /app
RUN container build
```

In a Dockerfile for PHP 7 without Hem and 6.x version of NodeJS:
```Dockerfile
FROM quay.io/continuouspipe/magento2-nginx-php7-ng:latest

ARG GITHUB_TOKEN=
ARG MAGENTO_USERNAME=
ARG MAGENTO_PASSWORD=
ARG IMAGE_VERSION=3

COPY . /app
RUN container build
```

In a Dockerfile for PHP 7 with Hem and 6.x version of NodeJS:
```Dockerfile
FROM quay.io/continuouspipe/magento2-nginx-php7:latest

ARG GITHUB_TOKEN=
ARG MAGENTO_USERNAME=
ARG MAGENTO_PASSWORD=
ARG IMAGE_VERSION=3

COPY . /app
RUN container build
```

## How to build
```bash

docker-compose build magento2_php72_nginx_ng
docker-compose push magento2_php72_nginx_ng

docker-compose build magento2_php71_nginx_ng
docker-compose push magento2_php71_nginx_ng

docker-compose build magento2_php71_nginx
docker-compose push magento2_php71_nginx

docker-compose build magento2_php70_nginx_ng
docker-compose push magento2_php70_nginx_ng

docker-compose build magento2_php70_nginx
docker-compose push magento2_php70_nginx
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
* [the php-nginx image functions](../../php/nginx/README.md#custom-build-and-startup-scripts)

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
IMAGE_VERSION | The docker image version to use. Version 1 uses the install_magento*.sh scripts which can be hard to customise. Version 2 uses magento_functions.sh and does a temporary database installation during the "build" phase. Version 3 removes the legacy assets installation and supports Magento's [pipeline deployment](https://devdocs.magento.com/guides/v2.2/config-guide/deployment/pipeline/) in Magento 2.2+. | 1/2/3 | 3
PHP_MEMORY_LIMIT | PHP memory limit | - | 768M
PHP_MAX_EXECUTION_TIME | Amount of time in seconds that PHP is allowed to execute for | integer | 600
PRODUCTION_ENVIRONMENT | If true, magento DI will be compiled | true/false | false
APP_HOSTNAME | Web server's host name | \<projectname\>.docker | magento.docker
PUBLIC_ADDRESS | Magento base URL. Note that an underscore should not be used due to magento admin login using PHP's filter_var to check for domain validity. "_" is not a valid character in a domain name. |  https://\<projectname\>.docker/ | https://magento.docker/
FORCE_DATABASE_DROP | Drops the existing database before importing from assets | true/false | false
DATABASE_NAME | Magento database name | - | magentodb
DATABASE_USER | Magento database user | - | magento
DATABASE_USER_HOST | Host for the DATABASE_USER to be granted access from | hostname/ip/wildcard | %
DATABASE_PASSWORD | Magento database password | - | magento
DATABASE_ADMIN_USER | Optional MySQL database password to perform DBA operations, DATABASE_USER will be used if not specified | - | -
DATABASE_ADMIN_PASSWORD | Optional MySQL database password to perform DBA operations, DATABASE_PASSWORD will be used if not specified | - | -
DATABASE_HOST | Magento database host | - | database
ADDITIONAL_SETUP_SQL | Any additional SQL query which should be executed after database import (changing base URLs and setting varnish host/port is added by default) | SQL Query | -
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
AMQP_HOST | The hostname where RabbitMQ is installed. | string |
AMQP_PORT | The port to use to connect to RabbitMQ. | port number | 5672
AMQP_USER | The username for connecting to RabbitMQ. | string |
AMQP_PASSWORD | The password for connecting to RabbitMQ. | string |
AMQP_VIRTUALHOST | The virtual host for connecting to RabbitMQ. | string | "/"
MAGENTO_ENABLE_QUEUE | Should AMQP be used for queuing? | true/false | false
REDIS_HOST | Redis host name (to store cache and sessions) | - | redis
REDIS_PORT | Redis port | port number | 6379
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
MAGENTO_REDIS_FORCE_STANDALONE | Should the extension phpredis be used, or should Credis be forced to use it's own standalone implementation of the redis protocol. Set by default to true (use the standalone implementation) as it is more able to handle connection problems than phpredis. | true/false | true
MAGENTO_ADMIN_FRONTNAME | Magento backend frontname | - | admin
MAGENTO_ADMIN_FRONTNAME_REGEX_ESCAPED | The admin URL "front name" that is configured for the magento application. Please escape any regular expression special characters. | regex escaped string | value of MAGENTO_ADMIN_FRONTNAME
MAGENTO_PROTECT_ADMIN | Should IP whitelisting/Basic Auth be deployed for the MAGENTO_ADMIN_FRONTNAME_REGEX_ESCAPED path? | true/false | false
MAGENTO_ADMIN_HTPASSWD | The htpasswd format `username:hashed_password` to protect admin with. Leave blank to just use IP Whitelisting. | htpasswd format username/passwords | empty
MAGENTO_ADMIN_IP_WHITELIST | The comma separated list of whitelisted IP addresses that can visit the admin path. Leave blank to just use htpasswd | CSV of IP addresses | Value of $AUTH_IP_WHITELIST, which may be blank or "127.0.0.1/32, ::1, 10.0.0.0/14"
MAGENTO_ADMIN_USERNAME | If you would like to configure an admin user automatically (i.e. for development purposes), set this value to be the username for the admin user and MAGENTO_ADMIN_PASSWORD too. | string | empty
MAGENTO_ADMIN_PASSWORD | If you would like to configure an admin user automatically (i.e. for development purposes), set this value to be the password for the admin user (please make it secure!) and MAGENTO_ADMIN_USERNAME too. | string | empty
START_MODE | Start in "web" mode to serve a site, or "cron" mode to run the cron | (web|cron) | web
START_CRON | Start the cron if "true", regardless of START_MODE | true/false | false
RUN_REPORTS_CRON | When cron is running, should the outputting of the last minute's reports to stderr happen? | true/false | true
RUN_MAGENTO_CRON | When cron is running, should the magento cron run, or just the supporting web services that output logs? | true/false | true
MAGENTO_HTTP_CACHE_HOSTS | Comma separated list of upstream HTTP cache hosts (for example, varnish) that magento will PURGE when clearing full page cache | CSV of hostnames/IPs | empty
MAGENTO_HTTP_CACHE_PORT | Port to talk to on the upstream HTTP cache hosts | 1-65535 | 80
MAGENTO_ALLOW_ACCESS_TO_SETUP | Whether to allow access to the /setup URL or not | true/false | true
MAGENTO_ALLOW_ACCESS_TO_UPDATE | Whether to allow access to the /update URL or not | true/false | true
MAGENTO_CACHE_STATIC_ASSETS | If true, static assets under /static will be cached in varnish and potentially browsers for a very long time. We have made this an opt-in feature as you should ensure that the config value `dev/static/sign` is set to `1`, or you will find the next deployment doesn't update the assets for visitors who have visited your site before. | true/false | false
MAGENTO_ENABLE_CONFIG_CACHE | If true, enable this cache type in /app/app/etc/env.php | true/false | true
MAGENTO_ENABLE_LAYOUT_CACHE | If true, enable this cache type in /app/app/etc/env.php | true/false | true
MAGENTO_ENABLE_BLOCK_CACHE | If true, enable this cache type in /app/app/etc/env.php | true/false | true
MAGENTO_ENABLE_COLLECTION_CACHE | If true, enable this cache type in /app/app/etc/env.php | true/false | true
MAGENTO_ENABLE_REFLECTION_CACHE | If true, enable this cache type in /app/app/etc/env.php | true/false | true
MAGENTO_ENABLE_DDL_CACHE | If true, enable this cache type in /app/app/etc/env.php | true/false | true
MAGENTO_ENABLE_EAV_CACHE | If true, enable this cache type in /app/app/etc/env.php | true/false | true
MAGENTO_ENABLE_NOTIFICATION_CACHE | If true, enable this cache type in /app/app/etc/env.php | true/false | true
MAGENTO_ENABLE_FULLPAGE_CACHE | If true, enable this cache type in /app/app/etc/env.php | true/false | true
MAGENTO_ENABLE_CONFIG_INTEGRATION_CACHE | If true, enable this cache type in /app/app/etc/env.php | true/false | true
MAGENTO_ENABLE_CONFIG_INTEGRATION_API_CACHE | If true, enable this cache type in /app/app/etc/env.php | true/false | true
MAGENTO_ENABLE_TRANSLATE_CACHE | If true, enable this cache type in /app/app/etc/env.php | true/false | true
MAGENTO_ENABLE_CONFIG_WEBSERVICE_CACHE | If true, enable this cache type in /app/app/etc/env.php | true/false | true
MAGENTO_ENABLE_TARGET_RULE_CACHE | If true, enable the target rule cache type in /app/app/etc/env.php. Enterprise edition only. | true/false | true
MAGENTO_ENABLE_COMPILED_CONFIG_CACHE | If true, enable the compiled_config cache type in /app/app/etc/env.php. Magento 2.2 onwards | true/false | true
MAGENTO_ENTERPRISE_EDITION | If true, this installation of magento is the enterprise edition which allows you to use the target rule cache. | true/false | false

The following variables have had their defaults changed from the php-nginx image so that Magento 2 runs better:

Variable | Description | Expected values | Default
--- | --- | --- | ----
PHP_MEMORY_LIMIT | The memory limit for PHP. | string | 768M
PHP_MAX_EXECUTION_TIME | How long in seconds can a PHP script run for? | integer | 600
PHP_OPCACHE_MAX_ACCELERATED_FILES | How many files PHP can cache into Opcache | integer | 130987
PHP_REALPATH_CACHE_SIZE | How many resolved file locations PHP can cache into the realpath cache. | string | 4096K
PHP_REALPATH_CACHE_TTL | How many seconds can PHP cache the resolved file locations in it's realpath cache | integer | 600
PHP_OPCACHE_INTERNED_STRINGS_BUFFER | The amount of megabytes of strings to store a cache of. | integer (megabytes) | 64
PHP_OPCACHE_MEMORY_CONSUMPTION | How much memory in megabytes can opcache use? | integer | 512
PHP_OPCACHE_ENABLE_CLI | Should opcache be enabled on the PHP CLI? | 0/1 | 1

## Pipeline Deployment Mode

If `IMAGE_VERSION` is set to `3` and you are using Magento 2.2 or above, you can use u the Magento 2.2+
[deployment pipeline](https://devdocs.magento.com/guides/v2.2/config-guide/deployment/pipeline/) for building the
docker image and upgrading sites during do_setup().

To use the pipeline feature, run `bin/magento app:config:dump` on an existing installation and commit the resulting
`app/etc/config.php`.

The minimum configuration in `app/etc/config.php` that you appear to need for setup:static-content:deploy to work is:
1. `modules`
2. `scopes`
3. `themes`
4. the `system -> default -> general -> locale -> code`
