# Magento 1 with Nginx

In a Dockerfile:
```Dockerfile
FROM quay.io/continuouspipe/magento1-nginx-php5.6:latest

ARG GITHUB_TOKEN=

COPY . /app
RUN container build

# Magento 1 with Apache

In a Dockerfile:
```Dockerfile
FROM quay.io/continuouspipe/magento1-apache-php5.6:latest

ARG GITHUB_TOKEN=

COPY . /app
RUN container build
```

## How to build
```bash
docker-compose build magento1_nginx magento1_apache
docker-compose push magento1_nginx magento1_apache
```

## About

These are Docker image that can install and serve a Magento 1 installation via PHP 5.6 with either NGINX or Apache.

## How to use

As for all images based on the ubuntu base image, see
[the base image README](../../ubuntu/16.04/README.md)

Before starting services, on boot the container will call the following scripts:

1. `bash /usr/local/share/magento1/install_magento.sh`, which is shared by the Dockerfile build, and should not contain
   references to external services such as databases which will not be present when built.
2. `bash /usr/local/share/magento1/install_magento_finalise.sh` which can contain calls to databases, redis, etc.

### Custom build and startup scripts

To run commands during the build and startup sequences that the base images add,
please add `usr/local/share/container/plan.sh` for a project, or
`usr/local/share/container/baseimage-{number}.sh` if creating another base image.

This allows you to define and override bash functions that the base images add.

In addition to the bash functions defined in this base image's parent images:
* [the base image functions](../../ubuntu/16.04/README.md#custom-build-and-startup-scripts)
* [the php-nginx image functions](../../php/nginx/README.md#custom-build-and-startup-scripts)
* [the php-apache image functions](../../php/apache/README.md#custom-build-and-startup-scripts)

This base image adds the following bash functions:

function | description | executed on
--- | --- | ---
do_magento_install | Builds Magento | do_build
do_magento_development_start | Installs Magento | do_development_start
do_magento_setup | Finalises the installation of Magento | Triggered manually

These functions can be triggered via the /usr/local/bin/container command, dropping off the "do_" part. e.g:

/usr/local/bin/container build # runs do_build
/usr/local/bin/container start_supervisord # runs do_start_supervisord

#### Environment variables

The following variables are supported

Variable | Description | Expected values | Default
--- | --- | --- | ----
PHP_MEMORY_LIMIT | PHP memory limit | - | 768M
PRODUCTION_ENVIRONMENT | If true, magento DI will be compiled | true/false | false
WEB_HOST | Web server's host name | \<projectname\>.docker | magento.docker
PUBLIC_ADDRESS_UNSECURE | Magento unsecure base URL. Note that an underscore should not be used due to magento admin login using PHP's filter_var to check for domain validity. "_" is not a valid character in a domain name. |  https://\<projectname\>.docker/ | https://$WEB_HOST/
PUBLIC_ADDRESS_SECURE | Magento secure base URL. Note that an underscore should not be used due to magento admin login using PHP's filter_var to check for domain validity. "_" is not a valid character in a domain name. |  https://\<projectname\>.docker/ | https://$WEB_HOST/
FORCE_DATABASE_DROP | Drops the existing database before importing from assets | true/false | false
DATABASE_NAME | Magento database name | - | magentodb
DATABASE_USER | Magento database user | - | magento
DATABASE_PASSWORD | Magento database password | - | magento
DATABASE_ADMIN_USER | Optional MySQL database password to perform DBA operations, DATABASE_USER will be used if not specified | - | -
DATABASE_ADMIN_PASSWORD | Optional MySQL database password to perform DBA operations, DATABASE_PASSWORD will be used if not specified | - | -
DATABASE_HOST | Magento database host | - | database
ADDITIONAL_SETUP_SQL | Any additional SQL query which should be executed after database import (changing base URLs and setting varnish host/port is added by default) | SQL Query | -
FRONTEND_INSTALL_DIRECTORY | NPM modules will be installed within this directory (if it exists) | absolute path (normally we mount the source at /app) | /app/tools/inviqa
FRONTEND_BUILD_DIRECTORY | Gulp command will be executed within this directory (if it exists) | absolute path (normally we mount the source at /app) | /app/tools/inviqa
FRONTEND_BUILD_ACTION | Gulp command to run | gulp command name | build
GULP_BUILD_THEME_NAME | If specified, will be passed to gulp command as "--theme=<theme name>" | - | -
MAGENTO_MODE | Used to set Magento mode. If set to "production", static contents will be deployed | default/developer/production | production
MAGENTO_RUN_CODE_MAPPING | Mapped to http_host and default store name. First part of the value is the host name and second part is magento's store code (separated by space). Don't forget to add ";" at the end. | - | magento_web.docker default;
FRONTEND_COMPILE_LANGUAGES | Used during static content deployment. It can be multiple language codes. | language code(s) separated by space | en_GB
MAGENTO_DEPENDENCY_INJECTION_COMPILE_COMMAND | Magento DI compile command | - | bin/magento setup:di:compile
MAGENTO_CRYPT_KEY | Magento crypt key | - | -
COMPOSER_CUSTOM_CONFIG_COMMAND | Used to set any custom composer configuration, will be executed before composer install | composer config .. | -
REDIS_HOST | Redis host name (to store cache and sessions) | - | redis
REDIS_PORT | Redis port | port number | 6379
MAGENTO_REDIS_CACHE_DATABASE | Redis database number to store block cache | database number | 0
MAGENTO_REDIS_FULL_PAGE_CACHE_DATABASE | Redis database number to store full page cache | database number | 1
MAGENTO_REDIS_SESSION_DATABASE | Redis database number to store sessions | database number | 2
MAGENTO_ADMIN_FRONTNAME | Magento backend frontname | - | admin
MEMCACHED_HOST | Hostname of the memcached storage for magento sessions | - | memcached
MEMCACHED_PORT | Port of the memcached storage for magento sessions | 1-65535 | 11211
START_MODE | Start in "web" mode to serve a site, or "cron" mode to run the cron | (web|cron) | web
