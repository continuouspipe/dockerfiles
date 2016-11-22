# PHP NGINX

```Dockerfile
FROM quay.io/continuouspipe/php-nginx:7.0
```

## How to build
```bash
docker build --pull --tag quay.io/continuouspipe/php-nginx:7.0 --rm .
docker push
```

## How to use

As for all images based on the ubuntu base image, see
[the base image README](../../ubuntu/16.04/README.md)
