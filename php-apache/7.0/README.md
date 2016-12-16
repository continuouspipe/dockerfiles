# PHP 7.0 base

```Dockerfile
# For PHP 7.0
FROM quay.io/continuouspipe/php7-apache:v1.0

# For PHP 5.6
FROM quay.io/continuouspipe/php5.6-apache:v1.0
```

## How to build
```bash
# For PHP 7.0
docker-compose build php_apache
docker-compose push php_apache

# For PHP 5.6
docker-compose build php56_apache
docker-compose push php56_apache
```

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
  export AUTH_HTTP_TYPE=Basic
  export AUTH_HTTP_FILE=/etc/apache2/custom-htpasswd-path
  ```
