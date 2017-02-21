# MAGENTO 2 VARNISH

```Dockerfile
FROM quay.io/continuouspipe/magento2-varnish4:stable
```

## How to build
```bash
docker build --pull --tag quay.io/continuouspipe/magento2-varnish:4.0 --rm .
docker push
```

## How to use

As for all images based on the ubuntu base image, see
[the base image README](../../ubuntu/16.04/README.md)
