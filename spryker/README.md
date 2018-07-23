# Spryker

In a Dockerfile for PHP 7.1 and NGINX:
```Dockerfile
FROM quay.io/continuouspipe/spryker-php7.1-nginx:stable

ARG IMAGE_VERSION=2
ARG GITHUB_TOKEN=
ENV IMAGE_VERSION="$IMAGE_VERSION"

COPY . /app
RUN container build
```

In a Dockerfile for PHP 7.1 and Apache:
```Dockerfile
FROM quay.io/continuouspipe/spryker-php7.1-apache:stable

ARG IMAGE_VERSION=2
ARG GITHUB_TOKEN=
ENV IMAGE_VERSION="$IMAGE_VERSION"

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

Spryker supports multiple environments for configuration purposes. You can set `APPLICATION_ENV` to the name of the
environment that you wish to activate in the docker container.

#### Config

The default `development` environment shipped with the Spryker demoshop has hardcoded values that are useful for the
Spryker Virtual Machine. If you don't need to keep compatibility with the VM, you can update the values to be
`getenv('ENVIRONMENT_VARIABLE')` versions instead of hardcoded values.

If you still need to keep compatibility, you can create a set of files like so:

`config/Shared/config_development-docker.php`:
```php
<?php
/**
 * This is the global runtime configuration for Yves and Generated_Yves_Zed in a development environment,
 * with overrides for environment variable driven configuration.
 */
include_once 'config_default-development.php';
include_once 'environment_variables.php';
```

`config/Shared/config_default-development-docker_DE.php`:
```php
<?php
include_once 'config_default-development_DE.php';
include_once 'environment_variables_DE.php';
include_once 'environment_variables-development_DE.php';
```

`config/Shared/environment_variables.php`:
```php
<?php

use Spryker\Shared\Application\ApplicationConstants;
use Spryker\Shared\Log\LogConstants;
use Spryker\Shared\Propel\PropelConstants;
use Spryker\Shared\Search\SearchConstants;
use Spryker\Shared\Session\SessionConstants;
use Spryker\Shared\Storage\StorageConstants;

// ---------- Propel
$config[PropelConstants::USE_SUDO_TO_MANAGE_DATABASE] = false;
$config[PropelConstants::ZED_DB_USERNAME] = getenv('DATABASE_USER');
$config[PropelConstants::ZED_DB_PASSWORD] = getenv('DATABASE_PASSWORD');
$config[PropelConstants::ZED_DB_HOST] = getenv('DATABASE_HOST');
$config[PropelConstants::ZED_DB_PORT] = getenv('DATABASE_PORT') ?: 5432;

// ---------- Redis
$config[StorageConstants::STORAGE_REDIS_HOST] = getenv('REDIS_HOST');
$config[StorageConstants::STORAGE_REDIS_PORT] = getenv('REDIS_HOST_PORT') ?: 6379;

// ---------- Session
$config[SessionConstants::YVES_SESSION_COOKIE_SECURE] = getenv('YVES_SESSION_COOKIE_SECURE');
$config[SessionConstants::ZED_SESSION_COOKIE_SECURE] = getenv('ZED_SESSION_COOKIE_SECURE');
$config[SessionConstants::YVES_SESSION_REDIS_HOST] = $config[StorageConstants::STORAGE_REDIS_HOST];
$config[SessionConstants::YVES_SESSION_REDIS_PORT] = $config[StorageConstants::STORAGE_REDIS_PORT];
$config[SessionConstants::ZED_SESSION_REDIS_HOST] = $config[SessionConstants::YVES_SESSION_REDIS_HOST];
$config[SessionConstants::ZED_SESSION_REDIS_PORT] = $config[SessionConstants::YVES_SESSION_REDIS_PORT];

// ---------- Logging
$config[LogConstants::LOG_FILE_PATH] = 'php://stderr';

// ---------- Elasticsearch
$config[ApplicationConstants::ELASTICA_PARAMETER__HOST]
    = $config[SearchConstants::ELASTICA_PARAMETER__HOST]
    = getenv('ELASTICSEARCH_HOST');
$config[ApplicationConstants::ELASTICA_PARAMETER__TRANSPORT]
    = $config[SearchConstants::ELASTICA_PARAMETER__TRANSPORT]
    = "http";
$config[ApplicationConstants::ELASTICA_PARAMETER__PORT]
    = $config[SearchConstants::ELASTICA_PARAMETER__PORT]
    = getenv('ELASTICSEARCH_HOST_PORT') ?: 9200;
```

`config/Shared/environment_variables_DE.php`:
```php
<?php

use Pyz\Shared\Newsletter\NewsletterConstants;
use Spryker\Shared\Application\ApplicationConstants;
use Spryker\Shared\Customer\CustomerConstants;
use Spryker\Shared\Payone\PayoneConstants;
use Spryker\Shared\Payolution\PayolutionConstants;
use Spryker\Shared\ProductManagement\ProductManagementConstants;
use Spryker\Shared\Propel\PropelConstants;
use Spryker\Shared\Session\SessionConstants;
use Spryker\Shared\ZedRequest\ZedRequestConstants;

// ---------- Yves host
$ENV_PROTOCOL_YVES = getenv('YVES_HOST_PROTOCOL'); //'http://'
$ENV_HOST_YVES = getenv('YVES_HOST');
$config[ApplicationConstants::HOST_YVES] = $ENV_HOST_YVES;
$config[ApplicationConstants::PORT_YVES] = '';
$config[ApplicationConstants::PORT_SSL_YVES] = '';
$config[ApplicationConstants::BASE_URL_YVES] = sprintf(
    '%s%s%s',
    $ENV_PROTOCOL_YVES,
    $config[ApplicationConstants::HOST_YVES],
    $config[ApplicationConstants::PORT_YVES]
);
$config[ApplicationConstants::BASE_URL_SSL_YVES] = sprintf(
    'https://%s%s',
    $config[ApplicationConstants::HOST_YVES],
    $config[ApplicationConstants::PORT_SSL_YVES]
);
$config[ProductManagementConstants::BASE_URL_YVES] = $config[ApplicationConstants::BASE_URL_YVES];
$config[PayolutionConstants::BASE_URL_YVES] = $config[ApplicationConstants::BASE_URL_YVES];
$config[NewsletterConstants::BASE_URL_YVES] = $config[ApplicationConstants::BASE_URL_YVES];
$config[CustomerConstants::BASE_URL_YVES] = $config[ApplicationConstants::BASE_URL_YVES];

// ---------- Zed host
$ENV_PROTOCOL_ZED = getenv('ZED_HOST_PROTOCOL'); //'http://'
$ENV_HOST_ZED = getenv('ZED_HOST');
$config[ApplicationConstants::HOST_ZED] = $ENV_HOST_ZED;
$config[ApplicationConstants::PORT_ZED] = '';
$config[ApplicationConstants::PORT_SSL_ZED] = '';
$config[ZedRequestConstants::HOST_ZED_API] = $ENV_HOST_ZED;
$config[ApplicationConstants::BASE_URL_ZED] = sprintf(
    '%s%s%s',
    $ENV_PROTOCOL_ZED,
    $config[ApplicationConstants::HOST_ZED],
    $config[ApplicationConstants::PORT_ZED]
);
$config[ApplicationConstants::BASE_URL_SSL_ZED] = sprintf(
    'https://%s%s',
    $config[ApplicationConstants::HOST_ZED],
    $config[ApplicationConstants::PORT_SSL_ZED]
);

$config[ZedRequestConstants::BASE_URL_ZED_API] = getenv('BASE_URL_ZED_API');
$config[ZedRequestConstants::BASE_URL_SSL_ZED_API] = getenv('BASE_URL_SSL_ZED_API');

// ---------- SSL
$config[ApplicationConstants::YVES_SSL_ENABLED] = true;
$config[SessionConstants::YVES_SSL_ENABLED] = true;
$config[ApplicationConstants::YVES_COMPLETE_SSL_ENABLED] = true;
$config[ApplicationConstants::ZED_SSL_ENABLED] = true;
$config[ZedRequestConstants::ZED_API_SSL_ENABLED] = false;

// ---------- Session
$config[SessionConstants::YVES_SESSION_COOKIE_DOMAIN] = $config[ApplicationConstants::HOST_YVES];

// ---------- Propel
$config[PropelConstants::ZED_DB_DATABASE] = getenv('DATABASE_NAME');
```

`config/Shared/environment_variables-development_DE.php`:
```php
<?php
use Spryker\Shared\Mail\MailConstants;
// ---------- Email
$config[MailConstants::MAILCATCHER_GUI] = sprintf('http://%s:%s', getenv('MAILCATCHER_HOST'), getenv('MAILCATCHER_HOST_PORT'));
```

#### Install Profiles

Spryker's demoshop ships with [install profiles](https://github.com/spryker/demoshop/tree/8335b1a/config/install)
which are a set of commands that run in sequence when `vendor/bin/install` is called.

Using these install profiles is a lot easier to customise than having to override individual `vendor/bin/console`
commands in these docker images. You can opt into using the install profiles by setting `ARG IMAGE_VERSION=2` and
`ENV IMAGE_VERSION=2` in your Dockerfile, then performing a split of the
[development install profile](https://github.com/spryker/demoshop/blob/8335b1acc930c4c39f592537c9d80727bec65a57/config/install/development.yml)
into multiple files.

The multiple files are:
1. `config/install/docker-build.yml` - used during `do_spryker_build` which happens during the docker image build. No
external services like elasticsearch, rabbitmq or redis are available. Any file modifications need to happen here.
2. `config/install/docker-install.yml` - used during `do_spryker_install` to set up external services like databases
and elasticsearch for the first time.
* `config/install/docker-migrate.yml` - used during `do_spryker_migrate` to update external services like databases
with updates to schema or data

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
YVES_WEB_INCLUDES | Glob of files to include in the Yves virtual host. | Space separated glob of files. | Apache: 000-default-* 001-yves-*, NGINX: default-* yves-*
ZED_WEB_INCLUDES | Glob of files to include in the Zed virtual host. | Space separated glob of files. | Apache: 000-default-* 002-zed-*, NGINX: default-* zed-*

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
