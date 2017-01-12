# Ubuntu Base

```Dockerfile
FROM quay.io/continuouspipe/ubuntu:16.04

COPY ./somedir /somedir

RUN container build
```

## How to build
```bash
docker build --pull --tag quay.io/continuouspipe/ubuntu:16.04 --rm .
docker push
```

## How to use

The `etc` and `usr` folders local to this README get copied into the image. That means we can influence any file in
`etc` or `usr` using Docker's layering filesystem.

Upon booting, `/bin/bash /usr/local/bin/supervisor_start` will run, which will:

1. Include environment variable definitions from /usr/local/share/env/
2. Optionally create a user and group to match the given file or directory on a mountpoint.
3. Run `confd` to render templates with environment variables.
4. Run any custom tasks in /usr/local/bin/supervisor_custom_start
5. Run supervisord to start services

### SupervisorD

We are using supervisord to control service startup and provide a way to handle zombie processes gracefully,
with supervisord becoming PID 1.

You can start any service you want by adding a config file into the `/etc/supervisor/conf.d` folder.
For example, to start NGINX, place the following in `etc/supervisor/conf.d/nginx.conf`:

```
[program:nginx]
command = /usr/sbin/nginx -g 'daemon off;'
stdout_logfile=/dev/stdout
stdout_logfile_maxbytes=0
stderr_logfile=/dev/stderr
stderr_logfile_maxbytes=0
user = root
autostart = true
autorestart = true
priority = 10
```

### ConfD

[ConfD](https://github.com/kelseyhightower/confd) is in use to provide templating support for configuration files.

ConfD is automatically run when an image starts, and crucially, it is run before anything else. That means you can
have an optional SupervisorD service like so, in `etc/confd/templates/supervisor/nginx.conf:

```
[program:nginx]
command = /usr/sbin/nginx -g 'daemon off;'
stdout_logfile=/dev/stdout
stdout_logfile_maxbytes=0
stderr_logfile=/dev/stderr
stderr_logfile_maxbytes=0
user = root
autostart = {{ getenv "START_NGINX" }}
autorestart = true
priority = 10
```

This is backed up by the confd configuration file: `etc/confd/conf.d/supervisor_nginx.conf`:

```
[template]
src   = "supervisor/nginx.conf.tmpl"
dest  = "/etc/supervisord/conf.d/nginx.conf"
mode  = "0644"
keys = [
]
```

### Default Environment Variables

To define default environment variables, for confd to use when rendering templates, place an export line in
a file in `usr/local/share/env/` for example `usr/local/share/env/40-stack` for stack images, or
`usr/local/share/env/30-framwork` for framework images. The resulting /usr/local/share/env/ files will be
imported in alphanumeric sort order (the same as directory listing order).

For example, a 40-stack file:
```bash
#!/bin/bash

export PHP_TIMEZONE=${PHP_TIMEZONE:-UTC}
export PHP_MEMORY_LIMIT=${PHP_MEMORY_LIMIT:-256M}
export APP_USER=${APP_USER:-www-data}
export APP_GROUP=${APP_GROUP:-www-data}
export START_NGINX=${START_NGINX:-false}
export START_PHP_FPM=${START_PHP_FPM:-false}
```
This will use any of the named variables that are defined outside of the container, for example if passed in through
docker-compose, they will be used instead of these defaults.

### Volume Permission Fixes

Using `/usr/local/share/bootstrap/trigger_update_permissions.sh`, we can create a user and group that matches up with
the user and group of the file/directory referenced by `WORK_DIRECTORY`.

The default values for these are given below, `false` to turn this functionality off by default, and `/app` to pick up
on the permissions of the `/app` directory:

```bash
export APP_USER_LOCAL=${APP_USER_LOCAL:-false}
export WORK_DIRECTORY=${WORK_DIRECTORY:-/app}
```

After creating the user/group, the APP_USER and APP_GROUP environment variables will be exported, allowing `confd` to
pick up on these for use in templates.

Please note that running services as this randomly created user/group could cause a security risk. For instance, in the
case of a web server, running the web server process with the same user or group as the code could let an attacker
alter any file in the codebase.

As such, only set APP_USER_LOCAL in development when using volumes.

### Custom build and startup scripts

To run commands during the build and startup sequences that the base images add,
please add `usr/local/share/container/plan.sh` for a project, or
`usr/local/share/container/baseimage-{number}.sh` if creating another base image.

This allows you to define and override bash functions that the base images add.

This base image adds the following bash functions:

function | description | executed on
do_build | By default does nothing in this image
do_start_supervisord | Runs do_start and do_supervisord
do_supervisord | Runs [supervisord](#SupervisorD) | do_start_supervisor
do_start | Runs the following bash functions | do_start_supervisor
do_update_permissions | Runs the [Volume Permission Fixes](#Volume Permission Fixes) | do_start
do_development_start | By default does nothing in this image | do_start
do_templating | Runs [confd](#ConfD) | do_start

These functions can be triggered via the /usr/local/bin/container command, dropping off the "do_" part. e.g:

/usr/local/bin/container build # runs do_build
/usr/local/bin/container start_supervisord # runs do_start_supervisord


## Known child images

- [php7-apache](../../php-apache/)
- [php7-nginx](../../php-nginx/)
- [hem:latest](../../hem)
- [nodejs:6.0](../../nodejs/6.0)
