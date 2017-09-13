# Symfony with Nginx

In a Dockerfile:
```Dockerfile
FROM quay.io/continuouspipe/symfony-php7.1-nginx:stable
ARG GITHUB_TOKEN=
ARG SYMFONY_ENV=prod

COPY . /app/
RUN container build
```

```Dockerfile
FROM quay.io/continuouspipe/symfony-php7-nginx:stable
ARG GITHUB_TOKEN=
ARG SYMFONY_ENV=prod

COPY . /app/
RUN container build
```

```Dockerfile
FROM quay.io/continuouspipe/symfony-php5.6-nginx:stable
ARG GITHUB_TOKEN=
ARG SYMFONY_ENV=prod

COPY . /app/
RUN container build
```

# Symfony with Apache

In a Dockerfile:
```Dockerfile
FROM quay.io/continuouspipe/symfony-php7.1-apache:stable
ARG GITHUB_TOKEN=
ARG SYMFONY_ENV=prod

COPY . /app/
RUN container build
```

```Dockerfile
FROM quay.io/continuouspipe/symfony-php7-apache:stable
ARG GITHUB_TOKEN=
ARG SYMFONY_ENV=prod

COPY . /app/
RUN container build
```

```Dockerfile
FROM quay.io/continuouspipe/symfony-php5.6-apache:stable
ARG GITHUB_TOKEN=
ARG SYMFONY_ENV=prod

COPY . /app/
RUN container build
```

## About

This is a series of images that let you run a Symfony application under different PHP and web server environments (NGINX or Apache).

## How to use

### Environment variables

The following variables are supported

Variable | Description | Expected values | Default
--- | --- | --- | ----
SYMFONY_DOCTRINE_MODE | Whether to use Doctrine migrations, schema update or nothing. Automatically detected based on installed composer packages by default | auto/migrations/schema/off | auto
SYMFONY_DOCTRINE_WAIT_TIMEOUT | The maximum time to wait for the database to become available during the database build | time in seconds | 10
SYMFONY_ENV | The Symfony env to use, when the app reads this variable | string | prod
SYMFONY_FLEX | Whether the project uses the symfony/flex component and folder structure | true/false | autodetected based on whether in composer.lock
SYMFONY_MAJOR_VERSION | The major version of Symfony that will be used | 2, 3 | auto-detected based on location of console script
SYMFONY_CONSOLE | The location of the Symfony console script | file path | auto-detected
SYMFONY_WEB_APP_ENV_REWRITE | Whether to use web/app_*.php when SYMFONY_ENV != prod | true, false | false
APP_ENDPOINT | The uri of the web application php endpoint | domain relative uri | auto-detected based on SYMFONY_ENV and SYMFONY_WEB_APP_ENV_REWRITE
APP_ENDPOINT_REWRITE | Determines whether to redirect urls that don't match webroot files to the APP_ENDPOINT | true/false | true
APP_ENDPOINT_REGEX | A regex used to define allowed application endpoints, see [site_phpfpm.conf.tmpl](https://github.com/continuouspipe/dockerfiles/blob/master/php/nginx/etc/confd/templates/nginx/site_phpfpm.conf.tmpl#L1) | string | auto-detected
APP_ENDPOINT_STRICT | Restricts allowed application endpoints to only that of the APP_ENDPOINT environment variable | true/false | true

The following variables have had their defaults changed from the php-nginx image so that Symfony runs better:

Variable | Description | Expected values | Default
--- | --- | --- | ----
PHP_MEMORY_LIMIT | The memory limit for PHP. | string | 256M
PHP_OPCACHE_MAX_ACCELERATED_FILES | How many files PHP can cache into Opcache | integer | 20000
PHP_REALPATH_CACHE_SIZE | How many resolved file locations PHP can cache into the realpath cache. | string | 4096K
PHP_REALPATH_CACHE_TTL | How many seconds can PHP cache the resolved file locations in it's realpath cache | integer | 600

### Custom build and startup scripts

To run commands during the build and startup sequences that the base images add,
please add `usr/local/share/container/plan.sh` for a project, or
`usr/local/share/container/baseimage-{number}.sh` if creating another base image.

This allows you to define and override bash functions that the base images add.

In addition to the bash functions defined in this base image's parent images:
* [the base image functions](../ubuntu/16.04/README.md#custom-build-and-startup-scripts)
* either [the php-nginx image functions](../php/nginx/README.md#custom-build-and-startup-scripts)
* or [the php-apache image functions](../php/apache/README.md#custom-build-and-startup-scripts)

This base image adds the following bash functions:

function | description | executed on
--- | --- | ---
do_symfony_build | Updates the permissions of the Symfony app as required for composer and web write access | do_composer
do_symfony_config_create | Creates an empty parameters.yml that the composer installation can update via the incenteev/parameters-handler package | do_symfony_build
do_symfony_directory_create | Creates directories that may not be present in the codebase but are required before composer can run to install dependencies | do_symfony_build
do_symfony_build_permissions | Fix the owner and permissions of the web-writable directories, to allow symfony to function | do_composer
do_cache_clear | Clears/warms up the Symfony cache | nothing by default
do_database_build | Installs or updates the database schema depending on whether the database exists | nothing by default
do_database_install | Runs database install process (assumes Doctrine ORM/migrations), which is by default do_database_schema_create, do_database_migrations_mark_done, do_database_fixtures | do_database_build
do_database_update | Runs database update process(assumes Doctrine ORM/migrations), which is by default do_database_migrate | do_database_build
do_database_schema_create | Runs doctrine:schema:create | do_database_install
do_database_schema_update | Runs doctrine:schema:update --force (not recommmended) | nothing by default
do_database_migrations_mark_done | Marks all Doctrine migrations as done | do_database_install
do_database_migrate | Runs doctrine:migrations:migrate --no-interaction | do_database_update

These functions can be triggered via the /usr/local/bin/container command, dropping off the "do_" part. e.g:

/usr/local/bin/container build # runs do_build
/usr/local/bin/container start_supervisord # runs do_start_supervisord
