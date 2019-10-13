# Drupal with Apache and PHP

In a Dockerfile:
```Dockerfile
FROM quay.io/continuouspipe/drupal-php7.1-apache:latest
ARG GITHUB_TOKEN=

COPY . /app
RUN container build
```

```Dockerfile
FROM quay.io/continuouspipe/drupal-php7-apache:latest
ARG GITHUB_TOKEN=

COPY . /app
RUN container build
```

```Dockerfile
FROM quay.io/continuouspipe/drupal-php5.6-apache:latest
ARG GITHUB_TOKEN=

COPY . /app
RUN container build
```

## How to build
```bash
docker-compose build drupal_php71_apache drupal_php70_apache drupal_php56_apache
docker-compose push drupal_php71_apache drupal_php70_apache drupal_php56_apache
```

## About

This is a Docker image that can support a Drupal 7 or 8 installation, running on Apache with PHP 5.6/7.0/7.1, depending 
on the image chosen.

## How to use

As for all images based on the ubuntu base image, see
[the base image README](../../ubuntu/16.04/README.md)

To finish the installation after basing your image off of this one, assuming you are using docker compose, please run:
```bash
docker-compose up -d database
GITHUB_TOKEN="<your github token>" docker-compose run web container setup
```

You can influence the installation process by placing functions in `/usr/local/share/container/plan.sh`
that extend or replace the functions found in `/usr/local/share/drupal/drupal_functions.sh`

### Environment variables

The following environment variables are supported

Variable | Description | Expected values | Default
---|---|---|---
DATABASE_NAME | The name of the database to connect to in the drupal installation | string | drupaldb
DATABASE_USER | The username to connect to the database with | string | drupal
DATABASE_PASSWORD | The password to connect to the database with | string | drupal
DATABASE_ADMIN_USER | Optional MySQL database password to perform DBA operations, DATABASE_USER will be used if not specified | - | -
DATABASE_ADMIN_PASSWORD | Optional MySQL database password to perform DBA operations, DATABASE_PASSWORD will be used if not specified | - | -
DATABASE_PREFIX | A prefix to apply to the tables in the database, if the database is being shared with other technology | string | empty
DATABASE_HOST | The database hostname to connect to | string | database
DATABASE_PORT | The port to connect to on the database host | 1-65535 | 3306
DRUPAL_DRUSH_ALIAS | The alias to apply to most drush commands, see /usr/local/share/drupal/drupal_functions.sh | string | empty
INSTALL_DRUPAL | Should Drupal be installed as part of the "setup" step? | true/false | true
DRUPAL_INSTALL_PROFILE | Profile to install drupal with, if INSTALL_DRUPAL is true | string | standard
FORCE_DATABASE_DROP | Should the database be wiped every time the "setup" step runs? | true/false | false
DRUPAL_ADMIN_USERNAME | A username fo the Drupal admin site | string | drupal-continuous-pipe-admin
DRUPAL_ADMIN_PASSWORD | A secure password for the Drupal admin site | string | backdrop

If you wish to download and restore a database dump from an existing installation via SSH, provide the following variables:

Variable | Description | Expected values | Default
---|---|---|---
DRUPAL_SYNC_SSH_KEY_NAME | The name of the SSH key to write out | a valid filename (string) | empty
DRUPAL_SYNC_SSH_PRIVATE_KEY | The private key of the user allowed to SSH to the remote location. | base64 encoded private key (string) | empty
DRUPAL_SYNC_SSH_PUBLIC_KEY | The public key of the user allowed to SSH to the remote location. | base64 encoded public key (string)  | empty
DRUPAL_SYNC_SSH_USERNAME | The username to connect to the remote SSH server as | string | empty
DRUPAL_SYNC_SSH_SERVER_HOST | The remote SSH server hostname to connect to | string | empty
DRUPAL_SYNC_SSH_SERVER_PORT | The remote SSH server port to connect to | 1-65535 | 22
DRUPAL_SYNC_SSH_KNOWN_HOSTS | The SSH known hosts file that contains the results of `ssh-keyscan -t rsa,ecdsa $DRUPAL_SYNC_SSH_SERVER_HOST` | base64 encoded known hosts file (string) | empty
DRUPAL_SYNC_DATABASE_FILENAME_GLOB | A glob to match files with, e.g. "/mnt/files/foo/backups/env-foo-bar*.sql.gz" . The file that has the latest date will be downloaded. | glob (string) | empty
DATABASE_ARCHIVE_PATH | The location in the container to download the database dump to, and then install from. | string | /tmp/database-backup.tar.gz


The following environment variables from parent images are overridden:

Variable | Description | Expected values | Default
---|---|---|---
WEB_DIRECTORY | The directory in which Drupal lives | Directory name in repository root | docroot

### Custom build and startup scripts

To run commands during the build and startup sequences that the base images add,
please add `usr/local/share/container/plan.sh` for a project, or
`usr/local/share/container/baseimage-{number}.sh` if creating another base image.

This allows you to define and override bash functions that the base images add.

In addition to the bash functions defined in this base image's parent images:
[the base image functions](../../ubuntu/16.04/README.md#custom-build-and-startup-scripts)
[the php-apache image functions](../../php/apache/README.md#custom-build-and-startup-scripts)

This base image adds the following bash functions:

function | description | executed on
--- | --- | --- |
do_drupal8_install | Builds Drupal | do_build 
do_drupal8_development_start | Installs Drupal | do_development_start  

These functions can be triggered via the /usr/local/bin/container command, dropping off the "do_" part. e.g:

````
/usr/local/bin/container build # runs do_build
/usr/local/bin/container start_supervisord # runs do_start_supervisord
````