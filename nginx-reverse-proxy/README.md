# NGINX Reverse Proxy

In a docker-compose.yml:
```yml
version: '3'
services:
  proxy:
    image: quay.io/continuouspipe/nginx-reverse-proxy:latest
    depends_on:
     - web
    environment:
      PROXY_LOCATIONS: '[{"location": "/", "backend": "https://web", "preserve_host": true}, {"location": "~ /foo(/|$)", "backend": "https://web/bar", "preserve_host": true}]'
  web:
    image: ...
```

```Dockerfile
FROM quay.io/continuouspipe/nginx-reverse-proxy:latest
```

## How to build
```bash
docker-compose build nginx_reverse_proxy
docker-compose push nginx_reverse_proxy
```

## About

This is a Docker image for using Nginx as a reverse proxy.

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

Alternatively, you can use multiple backends using the `backend_servers` configuration:
```
export PROXY_LOCATIONS='[{"location": "/", "backend_servers": ["google.com", "yahoo.com"], "backend_scheme": "http"}]'
```

Multiple locations can be specified. The only required keys per location are
location and backend.

Location settings available:

Key | Description | Expected values | Default
--- | --- | --- | ---
location | The domain-relative uri for which to apply the proxy configuration | domain-relative uri |
backend | The backend host to proxy for the location, note for domains, WEB_RESOLVER needs to be set | url |
preserve_host | Whether to pass the request's HTTP Host header value, or otherwise use the host from the backend setting | true/false | false
use_downstream_edge_headers | Whether to pass the downstream edge headers to the backend server, or send it's own | true/false | false
hide_edge_headers | Whether to hide edge headers from the backend server | true/false | false

As this is using NGINX's proxy module, check out the documentation here: https://nginx.org/en/docs/http/ngx_http_proxy_module.html#proxy_pass

### Edge vs intermediate reverse proxy header handling

Edge and intermediate reverse proxies should handle X-Forwarded-* headers differently.

Other than X-Forwarded-For, generally edge servers should ignore downstream
X-Forwarded-* headers as they are untrusted, yet intermediate servers may need
to proxy downstream X-Forwarded-* headers, if the edge servers set them.

This can be achieved by setting `use_downstream_edge_headers` to true for
intermediate servers, and false (which is the default) for edge servers.

X-Forwarded-For instead is fine the same for both, as it appends the next value
onto the end of the existing header value.

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
