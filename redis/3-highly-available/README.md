# Highly available Redis 3

In a Dockerfile:
```Dockerfile
FROM quay.io/continuouspipe/redis3-highly-available:stable
```

In a docker-compose.yml:
```yml
version: '3'
services:
  redis:
    image: quay.io/continuouspipe/redis3-highly-available:stable
```

## How to build
```bash
docker-compose build redis_highly_available
docker-compose push redis_highly_available
```

## About

Based on https://github.com/kubernetes/kubernetes/blob/master/examples/storage/redis/ but supporting the customisation
of the timeout for triggering a master failover.

## How to use

### Environment variables

The following variables are supported

Variable | Description | Expected values | Default
--- | --- | --- | ----
REDIS_MASTER_DOWN_AFTER_MILLISECONDS | How many milliseconds to wait before starting a master failover (if two or more redis sentinels agree) | integer (milliseconds) | 5000
