# NodeJS

For Node 7.0 in a Dockerfile:
```Dockerfile
FROM quay.io/continuouspipe/nodejs7:latest

COPY . /app
RUN container build
```
or in a docker-compose.yml:
```yml
version: '3'
services:
  node:
    image: quay.io/continuouspipe/nodejs7:latest
```

For Node 7.0 without extra packages, in a Dockerfile:
```Dockerfile
FROM quay.io/continuouspipe/nodejs7-small:latest

COPY . /app
RUN container build
```
or in a docker-compose.yml:
```yml
version: '3'
services:
  node:
    image: quay.io/continuouspipe/nodejs7-small:latest
```

For Node 6.0 in a Dockerfile:
```Dockerfile
FROM quay.io/continuouspipe/nodejs6:latest

COPY . /app
RUN container build
```
or in a docker-compose.yml:
```yml
version: '3'
services:
  node:
    image: quay.io/continuouspipe/nodejs6:latest
```

For Node 6.0 without extra packages, in a Dockerfile:
```Dockerfile
FROM quay.io/continuouspipe/nodejs6-small:latest

COPY . /app
RUN container build
```
or in a docker-compose.yml:
```yml
version: '3'
services:
  node:
    image: quay.io/continuouspipe/nodejs6-small:latest
```

## How to build
```bash
# For Node 7.0
docker-compose build nodejs7
docker-compose push nodejs7

# For Node 7.0 without extra packages
docker-compose build nodejs7_small
docker-compose push nodejs7_small

# For Node 6.0
docker-compose build nodejs6
docker-compose push nodejs6

# For Node 6.0 without extra packages
docker-compose build nodejs6_small
docker-compose push nodejs6_small
```

## About

This is a set of docker images that provide NodeJS 6.0 or 7.0, with or without some extra packages.

The docker images have the global log level set to "warn" and the following packages are installed:

* marked
* node-gyp
* gulp
* node-sass

The "small" versions of the images do not contain these packages.

## How to use

As for all images based on the ubuntu base image, see
[the base image README](../../ubuntu/16.04/README.md)
