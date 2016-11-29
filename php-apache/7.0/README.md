# PHP 7.0 base

```
FROM quay.io/continuouspipe/php-apache:7.0
```

### Basic authentication

This image has support for protecting websites with basic authentication.

To use this functionality:

1. Generate a suitable password string using a tool such as Lastpass.
2. Decide upon a username to authenticate with.
3. Run the following to generate the htpasswd line: `htpasswd -n <username>`
4. Provide this htpasswd line securely in the environment for this image as `BASIC_AUTH_HTPASSWD`
5. Also provide the following variable with some values either through docker-compose environment or in
   `/usr/local/share/env/custom_env_variables`:
  ```
  export BASIC_AUTH_ENABLED=true
  ```
6. You may also optionally configure the following in the same way:
  ```
  export BASIC_AUTH_REALM=Protected System
  export BASIC_AUTH_TYPE=Basic
  export BASIC_AUTH_FILE=/etc/apache2/custom-htpasswd-path
  ```
