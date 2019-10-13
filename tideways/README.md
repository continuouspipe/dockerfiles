# Tideways Daemon

In a Dockerfile:
```Dockerfile
FROM quay.io/continuouspipe/tideways:latest
```
or in a docker-compose.yml:
```yml
version: '3'
services:
  web:
    image: quay.io/continuouspipe/php7.1-nginx:latest
    links:
      - tideways

  tideways:
    image: quay.io/continuouspipe/tideways:latest
```

## How to build
```bash
docker-compose build tideways
docker-compose push tideways
```

## About

This is a Docker image for the Tideways Daemon process. It is talked to from php-nginx and php-apache images and this
daemon will forward the generated PHP profile logs to the Tideways API.

## How to use

As for all images based on the ubuntu base image, see
[the base image README](../../ubuntu/16.04/README.md)


#### Environment variables

The following variables are supported

Variable | Description | Expected values | Default
--- | --- | --- | ----
TIDEWAYS_HOSTNAME | The domain of the website to help filter in the Tideways UI | a domain | tideways-daemon
TIDEWAYS_ENVIRONMENT | The environment of the website to help filter in the Tideways UI, if your plan allows for more than one environment | string | production
