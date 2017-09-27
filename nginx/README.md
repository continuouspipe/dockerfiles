# NGINX

In a Dockerfile:
```Dockerfile
FROM quay.io/continuouspipe/nginx:stable

COPY . /app
RUN container build
```

In a docker-compose.yml:
```yml
version: '3'
services:
  web:
    image: quay.io/continuouspipe/nginx:stable
```

## How to build
```bash
docker-compose build nginx
docker-compose push nginx
```

## About

This is a Docker image for Nginx. It uses, by
default, our recommended default configuration, including:

* A default HTTPS only website, with HTTP redirecting to HTTPS
* A self signed SSL certificate auto-generated on container start
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
WEB_RESOLVER        | DNS resolver for proxy_pass and ssl_stapling_verify | ip address |
WEB_REVERSE_PROXIED | Whether to interpret X-Forwarded-Proto as the $custom_scheme and $custom_https emulation. | true/false | true
WEB_SSL_CIPHERS | The enabled SSL/TLS server ciphers | the format understood by the OpenSSL library | ECDH+AESGCM:DH+AESGCM:ECDH+AES256:DH+AES256:ECDH+AES128:DH+AES:ECDH+3DES:DH+3DES:RSA+AESGCM:RSA+AES:RSA+3DES:!aNULL:!MD5:!DSS
WEB_SSL_FULLCHAIN | The location of the SSL certificate and intermediate chain file | absolute filename | /etc/ssl/certs/fullchain.pem
WEB_SSL_OCSP_STAPLING | Whether to enable TLS OCSP stapling | true/false | false
WEB_SSL_PRIVKEY | The location of the SSL private key file | absolute filename | /etc/ssl/private/privkey.pem
WEB_SSL_PROTOCOLS | The SSL/TLS protocols to enable | [SSLv2] [SSLv3] [TLSv1] [TLSv1.1] [TLSv1.2] [TLSv1.3] | TLSv1 TLSv1.1 TLSv1.2
WEB_SSL_SESSION_CACHE | Sets the types and sizes of caches that store session parameters. See nginx ssl_session_cache documentation for more info | off/none/builtin[:size]/shared:name:size | none
WEB_SSL_SESSION_TIMEOUT | Specifies a time during which a client may reuse the session parameters. | time | 5m
WEB_SSL_TRUSTED_CERTIFICATES | The trusted certificates to use for OSCP stapling verification and/or SSL client certificate authentication | absolute filename | 
NGINX_LOG_FORMAT_NAME | Which log format to use for the access log. Two are currently available: combined (provided by NGINX) or combined_with_x_forwarded_for which logs the whole X-Forwarded-For header. | string | combined
WEB_INCLUDES | A space separated list of files in /etc/nginx/sites-enabled/ to include. ".conf" will be appended automatically. Globs are accepted. | space separated list of partial file names | default-*
WEB_DEFAULT_SERVER | True if the virtual host should be used for any unmatched traffic | true/false | true

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
7. If basic authentication is enabled but a certain user agent needs to be able to bypass the basic authentication
   for a healthcheck, `AUTH_HTTP_HEALTHCHECK_USER_AGENT` can be configured and a 200 will be returned.
8. If basic authentication is enabled but a certain location needs to be able to bypass the basic authentication
   for a healthcheck, `AUTH_HTTP_HEALTHCHECK_LOCATION` can be configured and a 200 will be returned.

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
do_nginx | Runs nginx-related setup scripts | do_start
do_https_certificates | Ensures there are [HTTPS certificates](#ssl-certificateskey) | do_nginx
do_build_permissions | Ensures that /app is owned by the build user and not www-data or root, for security and ability to run composer as a non-root user | do_build, do_development_start

These functions can be triggered via the /usr/local/bin/container command, dropping off the "do_" part. e.g:

/usr/local/bin/container build # runs do_build
/usr/local/bin/container start_supervisord # runs do_start_supervisord
