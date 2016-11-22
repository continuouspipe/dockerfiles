# Ubuntu Base

```Dockerfile
FROM quay.io/continuouspipe/ubuntu:16.04
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
2. Run `confd` to render templates with environment variables.
3. Run any custom tasks in /usr/local/bin/supervisor_custom_start
4. Run supervisord to start services

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
`usr/local/share/env/default_env_variables` for base images, or `usr/local/share/env/custom_env_variables` for images
where you wish to override the defaults.

For example, a default_env_variables:
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

### Custom Startup Scripts

To run custom scripts before a service starts, please add `usr/local/bin/supervisor_custom_start` in your child image
and it will automatically be executed before supervisor is started.

## Known child images

- [php-apache:7.0](../../php-apache/7.0)
- [php-nginx:7.0](../../php-nginx/7.0)
- [hem:latest](../../hem)
- [nodejs:6.0](../../nodejs/6.0)
