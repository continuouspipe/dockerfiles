# PHP Apache

For PHP 7.0 in a Dockerfile:
```Dockerfile
FROM quay.io/continuouspipe/php7-apache:stable
ARG GITHUB_TOKEN=

COPY . /app
RUN container build
```
or in a docker-compose.yml:
```yml
version: '3'
services:
  web:
    image: quay.io/continuouspipe/php7-apache:stable
```

For PHP 5.6 in a Dockerfile:
```Dockerfile
FROM quay.io/continuouspipe/php5.6-apache:stable
ARG GITHUB_TOKEN=

COPY . /app
RUN container build
```
or in a docker-compose.yml:
```yml
version: '3'
services:
  web:
    image: quay.io/continuouspipe/php5.6-apache:stable
```

## How to build
```bash
# For PHP 7.0
docker-compose build php70_apache
docker-compose push php70_apache

# For PHP 5.6
docker-compose build php56_apache
docker-compose push php56_apache
```

## About

This is a Docker image for PHP (using the mod_php SAPI) and Apache HTTPd. It uses,
by default, our recommended default configuration, including:

* A default HTTPS only website, with HTTP redirecting to HTTPS
* A self signed SSL certificate auto-generated on container start
* X-Forwarded-Proto being used as the request scheme if present

Most of these settings can be changed with [environment variables](#environment-variables)

## How to use

As for all images based on the ubuntu base image, see
[the base image README](../../ubuntu/16.04/README.md)

### Adding/replacing Apache HTTPd configuration

The image supports a single server (virtual host) by default:

/etc/apache2/sites-enabled/000-default.conf

This server configuration is split out into separate component files:

/etc/apache2/sites-available/000-default-05-custom_scheme_flags.conf
/etc/apache2/sites-available/000-default-10-base.conf
/etc/apache2/sites-available/000-default-20-rewriteapp.conf

These are generated from confd templates, which can be manipulated via:

* environment variables
* inserting additional files matching the /etc/apache2/sites-available/000-default-*.conf
* replacing individual files


#### Environment variables

The following variables are supported

Variable | Description | Expected values | Default
--- | --- | --- | ----
WEB_HOST | The domain of the website | a domain | localhost
WEB_HTTP | Whether to support HTTP traffic on the WEB_HTTP_PORT. | true/false/(deprecated: auto) | auto
WEB_HTTP_PORT | The port to serve the HTTP traffic or redirect from | 0-65535 | 80
WEB_HTTPS | Whether to support HTTPS traffic on the WEB_HTTPS_PORT | true/false | true
WEB_HTTPS_PORT | The port to serve the HTTPS traffic from | 0-65535 | 443
WEB_HTTPS_OFFLOADED | Whether the HTTPS traffic has been forwarded without SSL to the HTTPS port | true/false | false
WEB_HTTPS_ONLY      | Whether to redirect all HTTP traffic to HTTPS | true/false | $WEB_HTTPS (deprecated: if $WEB_HTTPS=true then false)
WEB_REVERSE_PROXIED | Whether to interpret X-Forwarded-Proto as the $custom_scheme and $custom_https emulation. | true/false | true
WEB_SSL_FULLCHAIN | The location of the SSL certificate and intermediate chain file | absolute filename | /etc/ssl/certs/fullchain.pem
WEB_SSL_PRIVKEY | The location of the SSL private key file | absolute filename | /etc/ssl/private/privkey.pem
SENDMAIL_RELAY_HOST | The MTA host to relay PHP's mail() to. PHP mail() will return false if not set | a domain
SENDMAIL_RELAY_PORT | The MTA port to relay PHP's mail() to | 0-65535 | 25
SENDMAIL_RELAY_USER | The user to authenticate with the relay. Anonymous SMTP used if not set | relay's username
SENDMAIL_RELAY_PASSWORD | The password to authenticate with the relay | relay's password
SENDMAIL_RELAY_TLS_SECURITY_LEVEL | Controls whether to use TLS, and what authentication of TLS | http://www.postfix.org/postconf.5.html#smtp_tls_security_level | may
PHP_MEMORY_LIMIT | The PHP Memory Limit, with unit suffix | Integer and a unit (K for Kilobytes/M for Megabytes/G for Gigabytes) | 256M
PHP_MEMORY_LIMIT_CLI | The PHP Memoery Limit on the Command Line | Integers and a unit (K for Kilobytes/M for Megabytes/G for Gigabytes) | value of PHP_MEMORY_LIMIT
PHP_OPCACHE_MAX_ACCELERATED_FILES | The amount of files to cache the opcodes for. | integer | 2000
PHP_OPCACHE_MEMORY_CONSUMPTION | The amount of megabytes that the opcode cache is allowed to use | integer | 64
PHP_OPCACHE_VALIDATE_TIMESTAMPS | If PHP should use the cache directly or first check if the file has been modified, where 0 means don't check files. This will automatically be set to 0 if DEVELOPMENT_MODE is "false" | 0/1 | 0 if DEVELOPMENT_MODE is false, 1 otherwise
PHP_REALPATH_CACHE_SIZE | The amount of bytes used for the cache of fully resolved file paths | Integer and a unit (K for Kilobytes/M for Megabytes/G for Gigabytes) | 16K
PHP_REALPATH_CACHE_TTL | The amount of seconds to cache the fully resolved file paths for | integer | 120
DEVELOPMENT_MODE | If set to "false", composer will run with the "--no-dev" flag to not bring in development dependencies. If set to "true", development dependencies will be brought in | true/false | false
COMPOSER_INSTALL_FLAGS | Additional flags to pass to "composer install", such as "--no-plugins". If providing this variable, you should include the default composer flags if you wish to keep them. | valid composer install flags | --no-interaction --optimize-autoloader (plus --no-dev if DEVELOPMENT_MODE is false)
TIDEWAYS_ENABLED | Should Tideways be enabled? | true/false | false
TIDEWAYS_FRAMEWORK | What framework (if any) is being used in the image? | string (one of https://tideways.io/profiler/docs/setup/installation#framework-configuration ) | empty
TIDEWAYS_API_KEY | Your Tideways API key | string | empty
TIDEWAYS_CONNECTION | The location of a Tideways daemon to send logs/instrumentation to. We recommend deploying https://github.com/continuouspipe/dockerfiles/tree/master/tideways to handle this | protocol://domain_or_ip:port | tcp://tideways:9135
TIDEWAYS_SERVICE | The service that your application provides (optional) | string | empty
XDEBUG_REMOTE_ENABLED | If XDebug is enabled for debugging purposes. We recommend disabling Tideways and only using XDebug in development. | true/false | false
XDEBUG_REMOTE_HOST | The host to connect to. We recommend deploying https://github.com/continuouspipe/dockerfiles/tree/master/ssh-forward to handle this | A domain or IP address | sshforward
XDEBUG_REMOTE_PORT | The port to connect to. | 1-65535 | 9000

The project using the image can define these environment variables to control
what is rendered in the Apache HTTPd configuration

#### Inserting additional files

You can place additional files that match /etc/apache2/sites-available/000-default-*.conf,
which will be imported in order of filenames. Numbers are used in the filenames
in order to control the order. Placing a configuration with a lower number will
interpret it earlier in the configuration, as will a higher number later.

The project using the image can either insert static configuration directly, or
use confd to add templates which render to the right location.

#### Replacing individual files

You can replace the existing files in a project, but keep in mind that replacing
them means you wont get any updates from newer image versions, so it's better
to try and work out a generic solution to Pull Request to the dockerfile repository.

### SSL Certificates/key

By default the image will generate a self-signed certificate if the SSL certificate
chain ($WEB_SSL_FULLCHAIN) and private key ($WEB_SSL_PRIVKEY) don't already exist.

It will use a common name of $WEB_HOST.

For a valid SSL certificate, it's recommended if you can use Kubernetes secrets
or Hashicorp Vault to populate a secret volume to point the environment variables at.

### Basic authentication

This image has support for protecting websites with basic authentication.

To use this functionality:

1. Generate a suitable password string using a tool such as Lastpass.
2. Decide upon a username to authenticate with.
3. Run the following to generate the htpasswd line: `htpasswd -n <username>`
4. Provide this htpasswd line securely in the environment for this image as `AUTH_HTTP_HTPASSWD`
5. Also provide the following variable with some values either through docker-compose environment or in
   `/usr/local/share/env/`:
  ```
  export AUTH_HTTP_ENABLED=true
  ```
6. You may also optionally configure the following in the same way:
  ```
  export AUTH_HTTP_REALM=Protected System
  export AUTH_HTTP_TYPE=Basic
  export AUTH_HTTP_FILE=/etc/apache2/custom-htpasswd-path
  ```

### IP Whitelist

This image has support for protecting websites with IP whitelisting.

To use this functionality:

1. Provide the following variables with some values either through docker-compose environment or in
   `/usr/local/share/env/`:
  ```
  export AUTH_IP_WHITELIST_ENABLED=true
  ```

2. By default when enabled, the loopback ips are whitelisted
  ```
  export AUTH_IP_WHITELIST=${AUTH_IP_WHITELIST:-
    127.0.0.0/8,
    ::1
  }
  ```
You can add IPs to this entry to allow more fixed IP addresses be whitelisted.

When used in conjunction with basic authentication, the IP whitelist will bypass the basic authentication

### Custom build and startup scripts

To run commands during the build and startup sequences that the base images add,
please add `usr/local/share/container/plan.sh` for a project, or
`usr/local/share/container/baseimage-{number}.sh` if creating another base image.

This allows you to define and override bash functions that the base images add.

In addition to the bash functions defined in this base image's parent images:
* [the base image functions](../ubuntu/16.04/README.md#custom-build-and-startup-scripts)

This base image adds the following bash functions:

function | description | executed on
--- | --- | ---
do_composer | Runs composer install in /app if it's not been run yet | do_build, do_development_start
do_composer_postinstall_scripts | runs composer post-install-cmd event to trigger scripts attached | nothing by default
do_build_permissions | Ensures that /app is owned by the build user and not www-data or root, for security and ability to run composer as a non-root user | do_build, do_development_start

These functions can be triggered via the /usr/local/bin/container command, dropping off the "do_" part. e.g:

/usr/local/bin/container build # runs do_build
/usr/local/bin/container start_supervisord # runs do_start_supervisord
