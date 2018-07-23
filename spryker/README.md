# Spryker

In a Dockerfile for PHP 7.1 and NGINX:
```Dockerfile
FROM quay.io/continuouspipe/spryker-php7.1-nginx:stable

ARG GITHUB_TOKEN=

COPY . /app
RUN container build
```

In a Dockerfile for PHP 7.1 and Apache:
```Dockerfile
FROM quay.io/continuouspipe/spryker-php7.1-apache:stable

ARG GITHUB_TOKEN=

COPY . /app
RUN container build
```

## How to build
```bash
docker-compose build spryker_php71_nginx
docker-compose push spryker_php71_nginx
```

## About

This is a Docker image that can install and serve a Spryker installation.

## How to use

### Application Environment

#### Config



### Environment variables

The following variables are supported:

Variable | Description | Expected values | Default
--- | --- | --- | ----
APPLICATION_ENV | Which application environment to load up for config and commands. | string | production
SPRYKER_CRON_COMMANDS | CSV of vendor/bin/console commands that should be run on a cron, should match /etc/confd/conf.d/cron_spryker.toml | CSV of strings | mailqueue:registration:send,oms:check-condition,oms:check-timeout,oms:clear-locks
ELASTICSEARCH_HOST | The hostname that elasticsearch is available on. | hostname | elasticsearch
ELASTICSEARCH_PORT | The TCP port that elasticsearch is available on. | 1-65535 | 9200
IMPORT_DEMO_DATA_COMMAND | Set a custom data import command for use in `do_spryker_import_demodata`. Must be a valid `vendor/bin/console` command name. | command name | data:import
REDIS_HOST | The hostname that redis is available on. | hostname | redis
REDIS_PORT | The TCP port that redis is available on. | 1-65535 | 6379
MAILCATCHER_HOST | The hostname that mailcatcher is available on. | hostname | mailcatcher
MAILCATCHER_PORT | The TCP port that mailcatcher is available on. | 1-65535 | 1080
YVES_HOST | The hostname that Spyker's Yves is available on, in "hostname:port" format if port is not 80/443. | hostname | yves
YVES_HOST_PROTOCOL | The HTTP protocol that Yves should be communicated with. Use http:// if SSL is offloaded. | https:// or http:// | https://
ZED_HOST |  The hostname that Spyker's Zed is available on, in "hostname:port" format if port is not 80/443. | hostname | zed
ZED_HOST_PROTOCOL | The HTTP protocol that Zed should be communicated with. Use http:// if SSL is offloaded. | https:// or http:// | https://
YVES_SESSION_COOKIE_SECURE | Should the cookie that Yves sets only be accessible over HTTPS? | true/false | true
ZED_SESSION_COOKIE_SECURE | Should the cookie that Zed sets only be accessible over HTTPS? | true/false | true
APP_SERVICES | What services does this container provide? Yves on it's own, Zed on it's own or both Yves and Zed? | "yves" or "zed" or "yves zed" | yves zed
ZED_WEB_DEFAULT_SERVER | For the Zed NGINX virtual host, should Zed be set as the "default" virtual host? | true/false | false
ZED_WEB_SERVER_NAME | Set a custom hostname to listen to for Zed in the virtual host | hostname | zed

### Custom build and startup scripts

To run commands during the build and startup sequences that the base images add,
please add `/app/plan.sh` for a project, or
`usr/local/share/container/baseimage-{number}.sh` if creating another base image.

This allows you to define and override bash functions that the base images add.

In addition to the bash functions defined in this base image's parent images:
* [the base image functions](../ubuntu/16.04/README.md#custom-build-and-startup-scripts)
* either [the php-nginx image functions](../php/nginx/README.md#custom-build-and-startup-scripts)
* or [the php-apache image functions](../php/apache/README.md#custom-build-and-startup-scripts)

This base image adds the following bash functions:

function | description | executed on
--- | --- | ---
do_spryker_vhosts | Run confd for YVES_* and ZED_* prefixed variables to create the Yves and Zed virtual hosts | do_templating
do_spryker_directory_create | Create directories that Spryker needs but shouldn't be committed to the codebase. | do_spryker_build
do_spryker_app_permissions | Ensure that the data directory is writable by the "$APP_USER" user. | do_spryker_build, do_spryker_install, do_development_start
do_spryker_config_create | Creates .pgpass for passwordless access to postgres in the root user's home directory | do_spryker_build, do_start
do_spryker_build | Set up directories and config. Run frontend setup for Yves/Zed. Generate all the files needed for Spryker to function and ensure they have the correct permissions. | do_build, do_development_start, do_setup
do_spryker_build_assets | Run the Yves/Zed frontend setup based on "$APP_SERVICES" | do_spryker_build
do_spryker_generate_files | Generate files needed by Spryker to function, including transfer files and propel configuration. | do_spryker_build
do_spryker_install | Run the Spryker installer if not already installed. Import data, setup search, etc. | do_development_start, do_setup
do_spryker_migrate | Run the propel migrations. | do_setup
do_spryker_run_collectors | Run the collectors. | do_spryker_install, `spryker_collectors_crons.conf.tmpl`
do_spryker_propel_install | Run the propel migrations. | do_spryker_migrate
do_spryker_import_demodata | Import the demo data into the Spryker install based on `$IMPORT_DEMO_DATA_COMMAND`. | do_spryker_install
do_spryker_product_label_relations_update | Run `vendor/bin/console product-label:relations:update` | do_spryker_install
do_spryker_setup_search | Run `vendor/bin/console setup:search` | do_spryker_install
do_spryker_run_tests | Run the codecept tests. | manual trigger
do_spryker_console | Run a vendor/bin/console command as the "$APP_USER" user, e.g. www-data. Usage: `container spryker_console <action>` | manual trigger

These functions can be triggered via the /usr/local/bin/container command, dropping off the "do_" part. e.g:

```bash
/usr/local/bin/container build # runs do_build
/usr/local/bin/container start_supervisord # runs do_start_supervisord
```
