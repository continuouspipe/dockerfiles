# MAGENTO 2 NGINX/FPM

```Dockerfile
FROM quay.io/continuouspipe/magento1-nginx-php5.6:v1.0
```

## How to build
```bash
docker-compose build magento1_nginx
docker-compose push magento1_nginx
```

## How to use

As for all images based on the ubuntu base image, see
[the base image README](../../ubuntu/16.04/README.md)

Before starting services, on boot the container will call the following scripts:

1. `bash /usr/local/share/magento1/install_magento.sh`, which is shared by the Dockerfile build, and should not contain
   references to external services such as databases which will not be present when built.
2. `bash /usr/local/share/magento1/install_magento_finalise.sh` which can contain calls to databases, redis, etc.
