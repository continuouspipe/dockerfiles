# PHP NGINX

```Dockerfile
FROM quay.io/continuouspipe/php-nginx:7.0
```

## How to build
```bash
docker build --pull --tag quay.io/continuouspipe/php-nginx:7.0 --rm .
docker push
```

## How to use

As for all images based on the ubuntu base image, see
[the base image README](../../ubuntu/16.04/README.md)


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
