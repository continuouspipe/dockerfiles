# CouchDB 1.6

In a docker-compose.yml:
```yml
version: '3'
services:
  database:
    image: quay.io/continuouspipe/couchdb1.6:latest
    environment:
      COUCHDB_USER: "myAdminUser"
      COUCHDB_PASSWORD: "A secret password for myAdminUser"
```

In a Dockerfile:
```Dockerfile
FROM quay.io/continuouspipe/couchdb1.6:latest
```

## How to build
```bash
./build.sh
docker-compose build --pull couchdb16
docker-compose push couchdb16
```

## About

This is a Docker image for CouchDB which tracks the upstream official image.

We heavily advise against exposing this image to the internet.

You should also consider making `/usr/local/var/lib/couchdb` a volume to persist data across container starts.

## How to use

As this is based on the library CouchDB image, see their README on
[The Docker Hub](https://hub.docker.com/_/couchdb/).

### Authentication

Authentication can be enabled by setting the environment variables COUCHDB_USER and COUCHDB_PASSWORD.
