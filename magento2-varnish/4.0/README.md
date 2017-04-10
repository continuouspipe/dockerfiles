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

### Environment variables

The following variables are supported

Variable | Description | Expected values | Default
--- | --- | --- | ----
MAGENTO_MODE | The magento mode that the varnish template should be supporting. In "developer" mode, Varnish will not cache static assets. | developer/production | production
PURGE_IPS | A comma or newline seperated list of IP addresses, hostnames or ranges that are allowed to send HTTP PURGE requests to Varnish, to clear caches. Ranges need their IP components quoted with \" | hostname/IP/IP Range | \"172.17.0.0\"/16,\"172.20.0.0\"/16,\"10.0.0.0\"/8

### More information
As for all images based on the ubuntu base image, see
[the base image README](../../ubuntu/16.04/README.md)
