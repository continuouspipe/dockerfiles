# Ubuntu Base

In a Dockerfile:
```Dockerfile
FROM quay.io/continuouspipe/ubuntu16.04:stable

COPY ./somedir /somedir

RUN container build
```

In a docker-compose.yml:
```yml
version: '3'
services:
  ubuntu:
    image: quay.io/continuouspipe/ubuntu16.04:stable
```

## How to build
```bash
docker build --pull --tag quay.io/continuouspipe/ubuntu16.04:stable --rm .
docker push
```

or:

```bash
docker-compose build ubuntu
docker-compose push ubuntu
```

## About

This is a Docker image that tracks the upstream library ubuntu image releases It also installs
common tooling for usage of the ContinuousPipe development environment tool, "cp-remote", as well
as providing a solid foundation for the rest of the base images in this repository.

## How to use

The `etc` and `usr` folders local to this README get copied into the image. That means we can influence any file in
`etc` or `usr` using Docker's layering filesystem.

Upon starting a container made from this image, `/bin/bash /usr/local/bin/container start_supervisord` will run. This will:

1. Include environment variable definitions from /usr/local/share/env/
2. Optionally create a user and group to match the given file or directory on a mountpoint.
3. Run `confd` to render templates with environment variables.
4. Run any custom tasks in /usr/local/bin/supervisor_custom_start
5. Run supervisord to start services

### Technical details of how supervisord gets started

1. Read in function definitions from:
 1.1. /usr/local/share/bootstrap/setup.sh
 1.2. /usr/local/share/bootstrap/common_functions.sh
2. Run "load_env()", which will include environment variable definitions from /usr/local/share/env/*, in alphanumerical order.
3. Read in function definitions from:
 3.1. /usr/local/share/container/baseimage-*.sh, in alphanumerical order.
 3.2. /usr/local/share/container/plan.sh
4. Execute the function "do_start_supervisord()", which will run "do_start()" and "do_supervisord()"

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

### Build user

The Docker image creates a utility user named "build". Images that base themselves on this image
can use the "build" user for installation processes that should not be run as root.

### Default Environment Variables

To define default environment variables for confd to use when rendering templates, place an export line in
a file in `usr/local/share/env/`.

#### How to declare variables

Here's an example from the php-apache image in this repository:
```bash
#!/bin/bash

export PHP_TIMEZONE=${PHP_TIMEZONE:-UTC}
export PHP_MEMORY_LIMIT=${PHP_MEMORY_LIMIT:-256M}
export APP_USER=${APP_USER:-www-data}
export APP_GROUP=${APP_GROUP:-www-data}
export START_NGINX=${START_NGINX:-false}
export START_PHP_FPM=${START_PHP_FPM:-false}
```

The repetition of the variable name inside ${} is to allow the passing through of a value that has already been defined beforehand.

For Docker, variables can be passed in by docker-compose.yml, the Dockerfile, or from the command line. ContinuousPipe can declare variables in the continuous-pipe.yml or any of the other Docker locations.

The default which is after the ":-" will be used if no value for the variable name has been given.

#### How to name your variables file

The files in the env folder are evaluated in alpha-numerical order, meaning the same order as when you list them in the directory.
This means that the lowest number will be read first. To ensure that project specific environment
variables override the defaults defined in the base images, define them in a
`usr/local/share/env/20-project` file, which would be read before a `usr/local/share/env/30-framework` file.

The naming convention for environment files that is used in these base images is:

* "20-project" for images that are used for your project
* "30-framework" for images that provide framework-specific functionality like the PHP frameworks Symfony, Magento or Drupal
* "40-stack" for images that provide infrastructure like web servers such as NGINX or Apache

### Volume Permission Fixes

Using the function `do_update_permissions()`, we can create a user and group that matches up with
the user and group of the file/directory referenced by `WORK_DIRECTORY` which is `/app` by default.

This will only be done if the value of `APP_USER_LOCAL` is `true`.

After creating the user/group, the APP_USER and APP_GROUP environment variables will be exported, allowing `confd` to
pick up on these for use in templates.

Please note that running services as this randomly created user/group could cause a security risk. For instance in the
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
--- | --- | ---
do_build | By default does nothing in this image, but is intended to perform installation steps where no external services such as databases are required. | manual trigger
do_start_supervisord | Runs do_start and do_supervisord | manual trigger
do_supervisord | Runs [supervisord](#SupervisorD) | do_start_supervisor
do_setup | By default does nothing in this image, but is intended to perform installation steps that need an external service. | manual trigger
do_start | Runs all of the bash functions defined below | do_start_supervisor
do_update_permissions | Runs the [Volume Permission Fixes](#Volume Permission Fixes) | do_start
check_development_start | Triggers "do_development_start" if "DEVELOPMENT_MODE" is set to true | do_start
do_templating | Runs [confd](#ConfD) | do_start
do_development_start | By default does nothing in this image, but is intended to repeat certain actions like "do_build()" if a mountpoint has overwritten what the image build did. | check_development_start

These functions can be triggered via the /usr/local/bin/container command, dropping off the "do_" part. e.g:

/usr/local/bin/container build # runs do_build
/usr/local/bin/container start_supervisord # runs do_start_supervisord


## Known child images

- [php7-apache](../../php-apache/)
- [php7-nginx](../../php-nginx/)
- [hem:latest](../../hem)
- [nodejs:6.0](../../nodejs/6.0)
