# Symfony 3 with Nginx

```
FROM quay.io/continuouspipe/symfony3-php7.1-nginx:v1.0
ARG GITHUB_TOKEN=

COPY . /app/
RUN container build
```

```
FROM quay.io/continuouspipe/symfony3-php7-nginx:v1.0
ARG GITHUB_TOKEN=

COPY . /app/
RUN container build
```

```
FROM quay.io/continuouspipe/symfony3-php5.6-nginx:v1.0
ARG GITHUB_TOKEN=

COPY . /app/
RUN container build
```

### Custom build and startup scripts

To run commands during the build and startup sequences that the base images add,
please add `usr/local/share/container/plan.sh` for a project, or
`usr/local/share/container/baseimage-{number}.sh` if creating another base image.

This allows you to define and override bash functions that the base images add.

In addition to the bash functions defined in this base image's parent images:
[the base image functions](../../ubuntu/16.04/README.md#Custom build and startup scripts)
[the php-nginx image functions](../../php-nginx/README.md#Custom build and startup scripts)

This base image adds the following bash functions:

function | desciption | executed on
do_symfony_build | Updates the permissions of the Symfony app as required for composer and web write access | do_composer

These functions can be triggered via the /usr/local/bin/container command, dropping off the "do_" part. e.g:

/usr/local/bin/container build # runs do_build
/usr/local/bin/container start_supervisord # runs do_start_supervisord