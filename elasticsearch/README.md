# Elasticsearch 2.4

In a docker-compose.yml:
```yml
version: '3'
services:
  elasticsearch:
    image: quay.io/continuouspipe/elasticsearch2.4:stable
```

In a Dockerfile:
```Dockerfile
FROM quay.io/continuouspipe/elasticsearch2.4:stable
```

## How to build
```bash
docker-compose build --pull elasticsearch
docker-compose push elasticsearch
```

## About

This is a Docker image that provides an Elasticsearch service that tracks the upstream Elasticsearch image.

## How to use

As this is based on the library Elasticsearch image, see their README on [The Docker Hub](https://hub.docker.com/_/elasticsearch/).
