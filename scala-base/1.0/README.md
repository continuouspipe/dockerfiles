# Scala base

In a docker-compose.yml:
```yml
version: '3'
services:
  scala:
    image: quay.io/continuouspipe/scala-base:stable
```

In a Dockerfile:
```Dockerfile
FROM quay.io/continuouspipe/scala-base:stable
```

## How to build
```bash
docker-compose build --pull scala_sbt
docker-compose push scala_sbt
```

## How to use

As for all images based on the ubuntu base image, see
[the base image README](../../ubuntu/16.04/README.md)

