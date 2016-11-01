# MAGENTO 2

```Dockerfile
FROM quay.io/inviqa_images/magento2-web:php-7.0
```

## How to build
```bash
docker build --pull --tag quay.io/inviqa_images/magento2-web:php-7.0 --rm .
docker push
```

## How to use

As for all images based on the ubuntu base image, see
[the base image README](../../ubuntu/16.04/README.md)
