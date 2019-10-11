# PHP NGINX

For PHP 7.2 in a Dockerfile:
```Dockerfile
FROM quay.io/continuouspipe/php7.2-nginx:latest
ARG GITHUB_TOKEN=

COPY . /app
RUN container build
```
or in a docker-compose.yml:
```yml
version: '3'
services:
  web:
    image: quay.io/continuouspipe/php7.2-nginx:latest
```

For PHP 7.1 in a Dockerfile:
```Dockerfile
FROM quay.io/continuouspipe/php7.1-nginx:latest
ARG GITHUB_TOKEN=

COPY . /app
RUN container build
```
or in a docker-compose.yml:
```yml
version: '3'
services:
  web:
    image: quay.io/continuouspipe/php7.1-nginx:latest
```

For PHP 7.0 in a Dockerfile:
```Dockerfile
FROM quay.io/continuouspipe/php7-nginx:latest
ARG GITHUB_TOKEN=

COPY . /app
RUN container build
```
or in a docker-compose.yml:
```yml
version: '3'
services:
  web:
    image: quay.io/continuouspipe/php7-nginx:latest
```

For PHP 5.6 in a Dockerfile:
```Dockerfile
FROM quay.io/continuouspipe/php5.6-nginx:latest
ARG GITHUB_TOKEN=

COPY . /app
RUN container build
```
or in a docker-compose.yml:
```yml
version: '3'
services:
  web:
    image: quay.io/continuouspipe/php5.6-nginx:latest
```

## How to build
```bash
# For PHP 7.1
docker-compose build php71_nginx
docker-compose push php71_nginx

# For PHP 7.0
docker-compose build php70_nginx
docker-compose push php70_nginx

# For PHP 5.6
docker-compose build php56_nginx
docker-compose push php56_nginx
```

## About

This is a Docker image for PHP (using the php-fpm SAPI) and Nginx. It uses, by
default, our recommended default configuration, including:

* A default HTTPS only website, with HTTP redirecting to HTTPS
* A self signed SSL certificate auto-generated on container start
* Nginx connecting to php-fpm using a private unix socket on the same container
* X-Forwarded-Proto being used as the request scheme if present
* A document root that isn't the root of the codebase, to avoid exposing other non-web files to the world - by default /app/web/

Most of these settings can be changed with [environment variables](#environment-variables)

## How to use

As for all images based on the ubuntu base image, see
[the base image README](../../ubuntu/16.04/README.md)

### Adding/replacing Nginx configuration

The image supports a single server (virtual host) by default:

/etc/nginx/sites-enabled/default

This server configuration is split out into separate component files:

* /etc/nginx/sites-available/default-05-custom_scheme_flags.conf
* /etc/nginx/sites-available/default-10-base.conf
* /etc/nginx/sites-available/default-20-rewriteapp.conf
* /etc/nginx/sites-available/default-30-phpfpm.conf

These are generated from confd templates, which can be manipulated via:

* environment variables
* inserting additional files matching the /etc/nginx/sites-available/default-*.conf
* replacing individual files


#### Environment variables

The following variables are supported

Variable | Description | Expected values | Default
--- | --- | --- | ----
WEB_HOST | The domain of the website | a domain | localhost
WEB_SERVER_NAME | The domain matched by the virtual host in NGINX. Default is to match any hostname. | string/regex | _
WEB_HTTP | Whether to support HTTP traffic on the WEB_HTTP_PORT. | true/false/(deprecated: auto) | auto
WEB_HTTP_PORT | The port to serve the HTTP traffic or redirect from | 0-65535 | 80
WEB_HTTPS | Whether to support HTTPS traffic on the WEB_HTTPS_PORT | true/false | true
WEB_HTTPS_PORT | The port to serve the HTTPS traffic from | 0-65535 | 443
WEB_HTTPS_OFFLOADED | Whether the HTTPS traffic has been forwarded without SSL to the HTTPS port | true/false | false
WEB_HTTPS_ONLY      | Whether to redirect all HTTP traffic to HTTPS | true/false | $WEB_HTTPS (deprecated: if $WEB_HTTPS=true then false)
WEB_HTTP2_TLS | Whether to enable HTTP2 over TLS on HTTPS port. If WEB_HTTPS_OFFLOADED enabled then this is ignored as TLS is not used | true/false | true
WEB_HTTP2_PLAINTEXT_NONBC | Whether to enable HTTP2 over plaintext on HTTP port (or HTTPS if WEB_HTTPS_OFFLOADED enabled). Nginx doesn't support h2c for plain HTTP protocol so will not support HTTP 1.1/1.0 if enabled | true/false | false
WEB_REVERSE_PROXIED | Whether to interpret X-Forwarded-Proto as the $custom_scheme and $custom_https emulation. | true/false | true
WEB_SSL_CIPHERS | The enabled SSL/TLS server ciphers | the format understood by the OpenSSL library | ECDH+ECDSA+AESGCM:ECDH+aRSA+AESGCM:DH+AESGCM:ECDH+ECDSA+AES256:ECDH+aRSA+AES256:DH+AES256:ECDH+ECDSA+AES128:ECDH+aRSA+AES128:DH+AES:${SSL_CIPHERS_3DES_DH}:${SSL_CIPHERS_RSA}:!aNULL:!MD5:!DSS
WEB_SSL_CIPHERS_SWEET32_FIX | Whether to disable 3DES ciphers found weak due to SWEET32 security flaw | true/false | false
WEB_SSL_CIPHERS_RSA_FIX | Whether to disable RSA encryption ciphers found weak due to potential future Bleichenbacher Oracle Threat variations | true/false | false
WEB_SSL_DHPARAM_CRON     | A cron schedule (based on crond format) to regenerate dhparam and gracefully reload the web server to reload the dhparam. Requires START_CRON=true on the same container as the web server. Set to "false" to disable | crond-format schedule / false | @daily
WEB_SSL_DHPARAM_ENABLE   | Whether to use a dhparam file for use for ECDHE/DHE SSL ciphers. Nginx (due to openssl defaults) uses a weak 1024 bit dhparam by default | true/false | false
WEB_SSL_DHPARAM_FILE     | The location of the dhparam file. If it doesn't exist, it will be generated | absolute filename | /etc/ssl/private/dhparam
WEB_SSL_DHPARAM_SIZE     | The size of the dhparam to generate if enabled. | number of bits | 2048
WEB_SSL_DHPARAM_TYPE     | Type of dhparam to generate if enabled, either dh or dsa. dh is most recommended for security but takes longer to generate | dh / dsa | dh
WEB_SSL_FULLCHAIN | The location of the SSL certificate and intermediate chain file | absolute filename | /etc/ssl/certs/fullchain.pem
WEB_SSL_OCSP_STAPLING | Whether to enable TLS OCSP stapling | true/false | false
WEB_SSL_PRIVKEY | The location of the SSL private key file | absolute filename | /etc/ssl/private/privkey.pem
WEB_SSL_PROTOCOLS | The SSL/TLS protocols to enable | [SSLv2] [SSLv3] [TLSv1] [TLSv1.1] [TLSv1.2] [TLSv1.3] | TLSv1 TLSv1.1 TLSv1.2
WEB_SSL_SESSION_CACHE | Sets the types and sizes of caches that store session parameters. See nginx ssl_session_cache documentation for more info | off/none/builtin[:size]/shared:name:size | none
WEB_SSL_SESSION_TIMEOUT | Specifies a time during which a client may reuse the session parameters. | time | 5m
WEB_SSL_TRUSTED_CERTIFICATES | The trusted certificates to use for OSCP stapling verification and/or SSL client certificate authentication | absolute filename |
WEB_INCLUDES | A space separated list of files in /etc/nginx/sites-enabled/ to include. ".conf" will be appended automatically. Globs are accepted. | space separated list of partial file names | default-*
WEB_DEFAULT_SERVER | True if the virtual host should be used for any unmatched traffic | true/false | true
APP_ENDPOINT | The uri of the web application php endpoint | domain relative uri | /index.php
APP_ENDPOINT_REWRITE | Determines whether to rewrite urls that don't match webroot files to the APP_ENDPOINT | true/false | true
APP_ENDPOINT_REGEX | A regex used to define allowed application endpoints, see [site_phpfpm.conf.tmpl](https://github.com/continuouspipe/dockerfiles/blob/master/php/nginx/etc/confd/templates/nginx/site_phpfpm.conf.tmpl#L1) | string | auto-detected
APP_ENDPOINT_STRICT | Restricts allowed application endpoints to only that of the APP_ENDPOINT environment variable | true/false | false
ASSETS_CLEANUP | Whether to delete the assets in ASSETS_PATH after they have been applied | true/false | true
ASSETS_ENV | The assets environment assets are downloaded/applied from. If unset no asset actions will happen | a asset environment |
ASSETS_PATH | The assets filesystem path assets are downloaded to /applied from. If unset and ASSETS_ENV unset no asset actions will happen | a asset filesystem path | tools/assets/${ASSETS_ENV} if ASSETS_ENV set
ASSETS_S3_BUCKET | The AWS S3 bucket assets are downloaded from. If unset, no assets will be downloaded | a S3 bucket name |
ASSETS_S3_BUCKET_PATH | The full bucket path to an environment's assets. If unset or ASSETS_S3_BUCKET unset, no assets will be downloaded | a S3 bucket path | s3://${ASSETS_S3_BUCKET}/${ASSETS_ENV}/ if ASSETS_S3_BUCKET and ASSETS_ENV set
ASSETS_DATABASE_ENABLED | Whether to import matched assets into the database | true/false | true
ASSETS_DATABASE_PATTERN | A regex pattern of database dump files in the ASSETS_PATH to apply to the database | a regex | /([^/\.]+)(\.[^/]*)?\.sql\.(gz|bz2)$
ASSETS_DATABASE_NAME_CAPTURE_GROUP | The capture group to use as the database name the database dump will be applied to, set to 0 to use DATABASE_NAME instead | positive integer | 1
ASSETS_DATABASE_WAIT_TIMEOUT | The maximum time to wait for the database to become available during the database import | time in seconds | 10
ASSETS_FILES_ENABLED | Whether to extract matched assets into the filesystem | true/false | true
ASSETS_FILES_PATTERN | A regex pattern of compressed file archives to extract into WORK_DIRECTORY | a regex | /([^/\.]+)(\.[^/]*)?\.sql(\.(gz|bz2))?$
DATABASE_PLATFORM | The platform of the database, e.g. mysql, postgres | mysql/postgres | mysql
SENDMAIL_RELAY_HOST | The MTA host to relay PHP's mail() to. PHP mail() will return false if not set | a domain
SENDMAIL_RELAY_PORT | The MTA port to relay PHP's mail() to | 0-65535 | 25
SENDMAIL_RELAY_USER | The user to authenticate with the relay. Anonymous SMTP used if not set | relay's username
SENDMAIL_RELAY_PASSWORD | The password to authenticate with the relay | relay's password
SENDMAIL_RELAY_TLS_SECURITY_LEVEL | Controls whether to use TLS, and what authentication of TLS | http://www.postfix.org/postconf.5.html#smtp_tls_security_level | may
NGINX_LOG_FORMAT_NAME | Which log format to use for the access log. Two are currently available: combined (provided by NGINX) or combined_with_x_forwarded_for which logs the whole X-Forwarded-For header. | string | combined
PHP_MEMORY_LIMIT | The PHP Memory Limit, with unit suffix | Integer and a unit (K for Kilobytes/M for Megabytes/G for Gigabytes) | 256M
PHP_MEMORY_LIMIT_CLI | The PHP Memoery Limit on the Command Line | Integers and a unit (K for Kilobytes/M for Megabytes/G for Gigabytes) | value of PHP_MEMORY_LIMIT
PHP_OPCACHE_INTERNED_STRINGS_BUFFER | The amount of megabytes of strings to store a cache of. | integer (megabytes) | 8
PHP_OPCACHE_MAX_ACCELERATED_FILES | The amount of files to cache the opcodes for. | integer | 2000
PHP_OPCACHE_MEMORY_CONSUMPTION | The amount of megabytes that the opcode cache is allowed to use | integer | 64
PHP_OPCACHE_VALIDATE_TIMESTAMPS | If PHP should use the cache directly or first check if the file has been modified, where 0 means don't check files. This will automatically be set to 0 if DEVELOPMENT_MODE is "false" | 0/1 | 0 if DEVELOPMENT_MODE is false, 1 otherwise
PHP_OPCACHE_ENABLE_CLI | Should opcache be enabled on the PHP CLI? | 0/1 | 0
PHP_REALPATH_CACHE_SIZE | The amount of bytes used for the cache of fully resolved file paths | Integer and a unit (K for Kilobytes/M for Megabytes/G for Gigabytes) | 16K
PHP_REALPATH_CACHE_TTL | The amount of seconds to cache the fully resolved file paths for | integer | 120
DEVELOPMENT_MODE | If set to "false", composer will run with the "--no-dev" flag to not bring in development dependencies. If set to "true", development dependencies will be brought in | true/false | false
PHPFPM_MAX_CHILDREN | The maximum number of PHP-FPM child processes. | integer | 5
PHPFPM_START_SERVERS | The amount of PHP-FPM child processes to start up initially. | integer | 2
PHPFPM_MIN_SPARE_SERVERS | The minimum number of spare PHP-FPM child processes. | integer | 1
PHPFPM_MAX_SPARE_SERVERS | The maximum number of spare PHP-FPM child processes. | integer | 3
COMPOSER_INSTALL_FLAGS | Additional flags to pass to "composer install", such as "--no-plugins". If providing this variable, you should include the default composer flags if you wish to keep them. | valid composer install flags | --no-interaction --optimize-autoloader (plus --no-dev if DEVELOPMENT_MODE is false)
TIDEWAYS_ENABLED | Should Tideways be enabled? | true/false | false
TIDEWAYS_FRAMEWORK | What framework (if any) is being used in the image? | string (one of https://tideways.io/profiler/docs/setup/installation#framework-configuration ) | empty
TIDEWAYS_API_KEY | Your Tideways API key | string | empty
TIDEWAYS_CONNECTION | The location of a Tideways daemon to send logs/instrumentation to. We recommend deploying https://github.com/continuouspipe/dockerfiles/tree/master/tideways to handle this | protocol://domain_or_ip:port | tcp://tideways:9135
TIDEWAYS_SERVICE | The service that your application provides (optional) | string | empty
TIDEWAYS_COLLECT | The collect mode for Tideways (see [the Tideways documentation](https://tideways.io/profiler/article/43-sampling))(optional) | DISABLED/BASIC/TRACING/PROFILING/FULL | TRACING
TIDEWAYS_SAMPLE_RATE | The sample rate for Tideways (see [the Tideways documentation](https://tideways.io/profiler/article/43-sampling))(optional) | integer | 25
XDEBUG_REMOTE_ENABLED | If XDebug is enabled for debugging purposes. We recommend disabling Tideways and only using XDebug in development. | true/false | false
XDEBUG_REMOTE_HOST | The host to connect to. We recommend deploying https://github.com/continuouspipe/dockerfiles/tree/master/ssh-forward to handle this. Alternatively see [Xdebug setup](#Xdebug-setup) | A domain or IP address | sshforward
XDEBUG_REMOTE_PORT | The port to connect to. | 1-65535 | 9000
XDEBUG_REMOTE_AUTOSTART | Whether to automatically start an Xdebug session upon every page/CLI request | true/false | false

The project using the image can define these environment variables to control
what is rendered in the Nginx configuration

#### Inserting additional files

You can place additional files that match /etc/nginx/sites-available/default-*.conf,
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
  export AUTH_HTTP_FILE=/etc/nginx/custom-htpasswd-path
  ```

We also support using the basic auth delegate feature of NGINX, by providing: `AUTH_HTTP_REMOTE_URL`.
Pretty please make this a HTTPS URL!

### IP Whitelisting

Entering basic authentication credentials each time can be tiresome. IP addresses separated by "," in `AUTH_IP_WHITELIST`
will be allowed to bypass the basic authentication section.

When basic authentication is turned off, the IP addresses whitelisted will be the only addresses allowed to access the
environment.

If there is another reverse proxy or load balancer in front of this container, set the IP or Hostname via `EXTERNAL_LOAD_BALANCER_HOST`
to get nginx to use it's realip functionality to work out from the client IP form the X-Forwarded-For header.
If a hostname is provided, the container will look up the IP address of `EXTERNAL_LOAD_BALANCER_HOST` to then pass to realip.

If there are more reverse proxies in between the client IP and this container, then follow [Real IP detection for logging and application fraud checks](#real-ip-detection-for-logging-and-application-fraud-checks).

### Real IP detection for logging and application fraud checks

If there are reverse proxies in between the client IP and this container, add the IPs of the proxies to
`TRUSTED_REVERSE_PROXIES`, separated by ",", for them to be removed from the X-Forwarded-For header.

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
do_nginx | Runs nginx-related setup scripts | do_start
do_https_certificates | Ensures there are [HTTPS certificates](#ssl-certificateskey) | do_nginx
do_build_permissions | Ensures that /app is owned by the build user and not www-data or root, for security and ability to run composer as a non-root user | do_build, do_development_start

These functions can be triggered via the /usr/local/bin/container command, dropping off the "do_" part. e.g:

/usr/local/bin/container build # runs do_build
/usr/local/bin/container start_supervisord # runs do_start_supervisord


### File and Database asset dump synchronisation from S3 and applying

This base image supports downloading asset dumps from S3, and applying them to
the filesystem and MySQL databases.

It can be used by setting the following environment variables
* ASSETS_ENV or ASSETS_PATH and ASSETS_S3_BUCKET_PATH
* ASSETS_S3_BUCKET or ASSETS_S3_BUCKET_PATH
* AWS_ACCESS_KEY_ID
* AWS_SECRET_ACCESS_KEY

By default, none of these are set, causing no action to be performed.

If ASSETS_ENV and ASSETS_S3_BUCKET are set, then assets will be downloaded from
s3://${ASSETS_S3_BUCKET}/${ASSETS_ENV} to /app/tools/assets/${ASSETS_ENV}.

These paths can alternatively be overridden via setting ASSETS_S3_BUCKET_PATH and
ASSETS_PATH environment variables respectively. You wouldn't need to specify
ASSETS_ENV or ASSETS_S3_BUCKET then.

#### Database

Database dumps that match ASSETS_DATABASE_PATTERNS will be, on container start,
extracted into a MySQL database named either by:

* The capture group in the regex pattern identified by ASSETS_DATABASE_NAME_CAPTURE_GROUP if ASSETS_DATABASE_NAME_CAPTURE_GROUP > 0
* DATABASE_NAME if ASSETS_DATABASE_NAME_CAPTURE_GROUP = 0

By default a database file with name `mydatabase.20170101.sql.gz` will match
`mydatabase` as the database name to import to.

The DATABASE_PLATFORM environment variable can be set to mysql or postgres,
allowing database import to either using mysql client or psql/createdb.

SQL files either plaintext or compressed by Gzip or Bzip2 are supported, with
the following file extensions:

* .sql
* .sql.gz
* .sql.bz2

This can be individually disabled using ASSETS_DATABASE_ENABLED.

#### Files

Files that match the ASSETS_FILES_PATTERN will be, on container start, extracted
into WORK_DIRECTORY, and therefore the archives must contain files with relative
paths to that directory.

Tar files either raw or compressed by Gzip or Bzip2 are supported, with the following file extensions:

* .tar
* .tgz
* .tar.gz
* .tar.bz2

This can be individually disabled using ASSETS_FILES_ENABLED.

### Xdebug setup

In local development environments, setting the following variables for this container, along with running the alias
command below, will let you connect directly to the container's Xdebug connection from your local machine:
```
XDEBUG_REMOTE_ENABLED: 'true'
XDEBUG_REMOTE_HOST: host.docker.internal # for docker-for-windows and docker-for-mac
XDEBUG_REMOTE_HOST: 10.254.254.254 # for Ubuntu
XDEBUG_REMOTE_PORT: '9000'
XDEBUG_REMOTE_AUTOSTART: 'true'
```

Xdebug will attempt to connect to `host.docker.internal` or `10.254.254.254` on port `9000`.

#### Ubuntu

To facilitate this you can alias `127.0.0.1` to the `10.254.254.254` address like so:

```
sudo ifconfig lo:1 10.254.254.254 up
```

#### IDE

You should now be able to use Xdebug by setting your IDE of choice to listen for connections.

**NOTE:** The path mapping should be `/app/` to your project directory.
