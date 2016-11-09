# MAGENTO 2 VARNISH

```Dockerfile
FROM quay.io/inviqa_images/drupal8-varnish:4.0
```

## How to build
```bash
docker build --pull --tag quay.io/inviqa_images/drupal8-varnish:4.0 --rm .
docker push
```

## How to use

As for all images based on the ubuntu base image, see
[the base image README](../../ubuntu/16.04/README.md)
