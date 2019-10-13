# Varnish

In a docker-compose.yml:
```yml
version: '3'
services:
  varnish:
    image: quay.io/continuouspipe/varnish4:latest
    environment:
      VARNISH_SECRET: "A secret that should remain secret!"
```

In a Dockerfile:
```Dockerfile
FROM quay.io/continuouspipe/varnish4:latest
```


## How to build
```bash
docker build varnish
docker push varnish
```

## About

This is a Docker image to provide a Varnish HTTP Cache service.

It ships with the bare minimum varnish configuration that would cache all responses marked with "Cache-Control: public" from the upstream server.

Before using this image or a HTTP Cache in general, please double check that your upstream server
and application sets the correct HTTP Cache headers.
This is especially important for data that should not be cached, such as pages on your website
that has a user's details on.

## How to use

### Environment variables

The following variables are supported

Variable | Description | Expected values | Default
--- | --- | --- | ----
VARNISH_CACHE_SIZE | The maximum amount of memory to use for caching content. Units are: small g for gigabyte, small m for megabyte, small k for kilobyte | string | 1g
VARNISH_START_PARAMS | Any extra parameters to pass through to the varnishd command on startup. | string | empty
VARNISH_BACKEND_HOST | The hostname or IP to fetch content from | hostname/IP | web
VARNISH_BACKEND_PORT | The TCP port of the VARNISH_BACKEND_HOST to fetch content from | 1-65535 | 80
VARNISH_SECRET | The varnish secret to write to /etc/varnish/secret to protect against anyone purging your cache. If nothing is provided and /etc/varnish/secret exists, the value in the secret file will be used instead. | string | empty

### More information

As for all images based on the ubuntu base image, see
[the base image README](../../ubuntu/16.04/README.md)
