# PHP NGINX

```Dockerfile
# For PHP 7.0
FROM quay.io/continuouspipe/php7-nginx:v1.0

# For PHP 5.6
FROM quay.io/continuouspipe/php5.6-nginx:v1.0
```

## How to build
```bash
# For PHP 7.0
docker-compose build php70_nginx
docker-compose push php70_nginx

# For PHP 5.6
docker-compose build php56_nginx
docker-compose push php56_nginx
```

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
WEB_HTTP | Whether to support HTTP traffic on the WEB_HTTP_PORT. If auto, it's behaviour is the reverse setting of WEB_HTTPS, and if false, will redirect to HTTPS. | true/false/auto | auto
WEB_HTTP_PORT | The port to serve the HTTP traffic or redirect from | 0-65535 | 80
WEB_HTTPS | Whether to support HTTPS traffic on the WEB_HTTPS_PORT | true/false | false
WEB_HTTPS_PORT | The port to serve the HTTPS traffic from | 0-65535 | 443
WEB_HTTPS_OFFLOADED | Whether the HTTPS traffic has been forwarded without SSL | true/false | false
WEB_REVERSE_PROXIED | Whether to interpret X-Forwarded-Proto as the $custom_scheme and $custom_https emulation. | true/false | $WEB_HTTPS_OFFLOADED

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

### Basic authentication

This image has support for protecting websites with basic authentication.

To use this functionality:

1. Generate a suitable password string using a tool such as Lastpass.
2. Decide upon a username to authenticate with.
3. Run the following to generate the htpasswd line: `htpasswd -n <username>`
4. Provide this htpasswd line securely in the environment for this image as `AUTH_HTTP_HTPASSWD`
5. Also provide the following variable with some values either through docker-compose environment or in
   `/usr/local/share/env/custom_env_variables`:
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
