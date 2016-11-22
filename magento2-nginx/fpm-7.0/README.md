# MAGENTO 2 NGINX/FPM

```Dockerfile
FROM quay.io/continuouspipe/magento2-nginx:fpm-7.0
```

## How to build
```bash
docker build --pull --tag quay.io/continuouspipe/magento2-nginx:fpm-7.0 --rm .
docker push
```

## How to use

As for all images based on the ubuntu base image, see
[the base image README](../../ubuntu/16.04/README.md)

Before starting services, on boot the container will call the following scripts:

1. `bash /usr/local/share/magento2/install_magento.sh`, which is shared by the Dockerfile build, and should not contain
   references to external services such as databases which will not be present when built.
2. `bash /usr/local/share/magento2/install_magento_finalise.sh` which can contain calls to databases, redis, etc.
