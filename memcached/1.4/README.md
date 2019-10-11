# Memcached

In a docker-compose.yml:
```yml
version: '3'
services:
  memcached:
    image: quay.io/continuouspipe/memcached1.4:latest
```

In a Dockerfile
```Dockerfile
FROM quay.io/continuouspipe/memcached1.4:latest
```

## How to build
```bash
docker-compose build memcached
docker-compose push memcached
```

## About

This is a Docker image to provide the Memcached daemon for volatile but fast storage and retrieval of data.

## How to use

As for all images based on the ubuntu base image, see
[the base image README](../../ubuntu/16.04/README.md)
