# MAGENTO 2 NGINX/FPM

```Dockerfile
FROM quay.io/continuouspipe/magento2-nginx-php7:stable
ARG GITHUB_TOKEN=

COPY . /app
RUN container build
```

## How to build
```bash
docker build --pull --tag quay.io/continuouspipe/magento2-nginx:fpm-7.0 --rm .
docker push
```

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
