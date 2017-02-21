# REDIS 3.2

```Dockerfile
FROM quay.io/continuouspipe/redis3:stable
```

## How to build
```bash
docker build --pull --tag quay.io/continuouspipe/redis3:stable --rm .
docker push
```

## How to use

As this is based on the library Redis image, see their README on [The Docker Hub](https://hub.docker.com/_/redis/).
