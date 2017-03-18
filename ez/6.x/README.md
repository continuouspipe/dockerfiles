# eZ 6

In a Dockerfile:
```Dockerfile
FROM quay.io/continuouspipe/ez6-apache-php7:latest

ARG GITHUB_TOKEN=

RUN container build
```

## How to build

```bash
docker-compose build ez
docker-compose push ez
```

## About

This is a Docker image that can serve an eZ website via Apache and PHP 7.0

## How to use

As for all images based on the ubuntu base image, see
[the base image README](../../ubuntu/16.04/README.md)