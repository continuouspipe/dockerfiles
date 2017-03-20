# Magento 2: Varnish

In a docker-compose.yml:
```yml
version: '3'
services:
  varnish:
    image: quay.io/continuouspipe/magento2-varnish4:stable
    environment:
      VARNISH_SECRET: "A secret for varnish that should be kept secret!"
```

In a Dockerfile:
```Dockerfile
FROM quay.io/continuouspipe/magento2-varnish4:stable
```

## How to build
```bash
docker-compose build magento2_varnish
docker-compose push magento2_varnish
```

## About

This is a Docker image that provides the Varnish HTTP Cache service with the configuration customised for Magento 2.

## How to use

As for all images based on the ubuntu base image, see
[the base image README](../../ubuntu/16.04/README.md)
