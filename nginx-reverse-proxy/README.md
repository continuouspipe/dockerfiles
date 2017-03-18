# NGINX Reverse Proxy

In a docker-compose.yml:
```yml
version: '3'
services:
  proxy:
    image: quay.io/continuouspipe/nginx-reverse-proxy:stable
    depends_on:
     - web
    environment:
      PROXY_LOCATIONS: '[{"location": "/", backend: "https://web", "preserve_host": true}, {"location": "~ /foo(/|$)", backend: "https://web/bar", "preserve_host": true}]'
  web:
    image: ...
```

```Dockerfile
FROM quay.io/continuouspipe/nginx-reverse-proxy:stable
```

## How to build
```bash
docker-compose build nginx_reverse_proxy
docker-compose push nginx_reverse_proxy
```

## About

This is a Docker image for using Nginx as a reverse proxy

## How to use

Define an environment variable which is a JSON array such as:
```bash
export PROXY_LOCATIONS='[
  {
    "location": "/",
    "backend": "https://example.com/",
    "preserve_host": true,
    "server_params": {
      "proxy_set_header My-Header": "My-Value"
    }
  }
]'
```

Multiple locations can be specified. The only required keys per location are
location and backend.

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
