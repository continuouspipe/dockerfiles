# Tideways Daemon

In a Dockerfile:
```Dockerfile
FROM quay.io/continuouspipe/tideways:stable
```
or in a docker-compose.yml:
```yml
version: '3'
services:
  web:
    image: quay.io/continuouspipe/php7.1-nginx:stable
    links:
      - tideways

  tideways:
    image: quay.io/continuouspipe/tideways:stable
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
