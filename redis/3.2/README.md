# Redis 3.2

In a docker-compose.yml:
```yml
version: '3'
services:
  redis:
    image: quay.io/continuouspipe/redis3:latest
```

In a Dockerfile:
```Dockerfile
FROM quay.io/continuouspipe/redis3:latest
```

## How to build
```bash
docker-compose build redis
docker-compose push redis
```

## How to use

As this is based on the library Redis image, see their README on [The Docker Hub](https://hub.docker.com/_/redis/).

The default configuration for Redis 3.2.7 will be used when not building a custom image from this one.
You can find the default configuration here:
[Redis 3.2.7 configuration](https://github.com/antirez/redis/blob/3.2.7/redis.conf).
