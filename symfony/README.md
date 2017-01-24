# Symfony with Nginx

```
FROM quay.io/continuouspipe/symfony-php7.1-nginx:stable
ARG GITHUB_TOKEN=
ARG SYMFONY_ENV=prod

COPY . /app/
RUN container build
```

```
FROM quay.io/continuouspipe/symfony-php7-nginx:stable
ARG GITHUB_TOKEN=
ARG SYMFONY_ENV=prod

COPY . /app/
RUN container build
```

```
FROM quay.io/continuouspipe/symfony-php5.6-nginx:stable
ARG GITHUB_TOKEN=
ARG SYMFONY_ENV=prod

COPY . /app/
RUN container build
```

# Symfony with Apache

```
FROM quay.io/continuouspipe/symfony-php7.1-apache:stable
ARG GITHUB_TOKEN=
ARG SYMFONY_ENV=prod

COPY . /app/
RUN container build
```

```
FROM quay.io/continuouspipe/symfony-php7-apache:stable
ARG GITHUB_TOKEN=
ARG SYMFONY_ENV=prod

COPY . /app/
RUN container build
```

```
FROM quay.io/continuouspipe/symfony-php5.6-apache:stable
ARG GITHUB_TOKEN=
ARG SYMFONY_ENV=prod

COPY . /app/
RUN container build
```

### Custom build and startup scripts

To run commands during the build and startup sequences that the base images add,
please add `usr/local/share/container/plan.sh` for a project, or
`usr/local/share/container/baseimage-{number}.sh` if creating another base image.

This allows you to define and override bash functions that the base images add.

In addition to the bash functions defined in this base image's parent images:
* [the base image functions](../ubuntu/16.04/README.md#custom-build-and-startup-scripts)
* either [the php-nginx image functions](../php-nginx/README.md#custom-build-and-startup-scripts)
* or [the php-apache image functions](../php-apache/README.md#custom-build-and-startup-scripts)

This base image adds the following bash functions:

function | description | executed on
--- | --- | ---
do_symfony_build | Updates the permissions of the Symfony app as required for composer and web write access | do_composer
do_symfony_config_create | Creates an empty parameters.yml that the composer installation can update via the incenteev/parameters-handler package | do_symfony_build
do_symfony_directory_create | Creates directories that may not be present in the codebase but are required before composer can run to install dependencies | do_symfony_build
do_symfony_build_permissions | Fix the owner and permissions of the web-writable directories, to allow symfony to function | do_composer

These functions can be triggered via the /usr/local/bin/container command, dropping off the "do_" part. e.g:

/usr/local/bin/container build # runs do_build
/usr/local/bin/container start_supervisord # runs do_start_supervisord
