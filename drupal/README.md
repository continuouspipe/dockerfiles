# DRUPAL 8 APACHE/PHP

```Dockerfile
FROM quay.io/continuouspipe/drupal8-apache-php7:stable
ARG GITHUB_TOKEN=

COPY . /app
RUN container build
```

## How to build
```bash
docker build --pull --tag quay.io/continuouspipe/drupal8-apache:7.0 --rm .
docker push
```

## How to use

As for all images based on the ubuntu base image, see
[the base image README](../../ubuntu/16.04/README.md)

To finish the installation after basing your image off of this one, assuming you are using docker compose, please run:
```bash
docker-compose up -d database
GITHUB_TOKEN="<your github token>" docker-compose run web /bin/bash /usr/local/share/drupal8/development/install.sh
```

You can also influence the installation process by placing commands in `/usr/local/share/drupal8/install_custom.sh`,
`/usr/local/share/drupal8/install_finalise_custom.sh` or `/usr/local/share/drupal8/development/install_custom.sh`.

These will get run at the end of the respective scripts, `/usr/local/share/drupal8/install.sh` and
`/usr/local/share/drupal8/install_finalise.sh` or `/usr/local/share/drupal8/development/install.sh`.

### Environment variables

The following environment variables are supported

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
[the php-apache image functions](../../php-apache/README.md#custom-build-and-startup-scripts)

This base image adds the following bash functions:

function | description | executed on
--- | --- | ---
* do_drupal8_install | Builds Drupal | do_build
* do_drupal8_development_start | Installs Drupal | do_development_start

These functions can be triggered via the /usr/local/bin/container command, dropping off the "do_" part. e.g:

/usr/local/bin/container build # runs do_build

/usr/local/bin/container start_supervisord # runs do_start_supervisord
