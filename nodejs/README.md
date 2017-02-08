# NodeJS, for SASS and Gulp

For Node 7.0
```Dockerfile
FROM quay.io/continuouspipe/nodejs7:stable

COPY . /app
RUN container build
```

For Node 6.0
```Dockerfile
FROM quay.io/continuouspipe/nodejs6:stable

COPY . /app
RUN container build
```

## How to build
```bash
# For Node 7.0
docker-compose build nodejs7
docker-compose push nodejs7

# For Node 6.0
docker-compose build nodejs6
docker-compose push nodejs6
```

## How to use

As for all images based on the ubuntu base image, see
[the base image README](../../ubuntu/16.04/README.md)
