# Magento 2: Varnish

In a docker-compose.yml:
```yml
version: '3'
services:
  varnish:
    image: quay.io/continuouspipe/magento2-varnish4:latest
    environment:
      VARNISH_SECRET: "A secret for varnish that should be kept secret!"
```

In a Dockerfile:
```Dockerfile
FROM quay.io/continuouspipe/magento2-varnish4:latest
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
PURGE_IPS | A comma or newline separated list of IP addresses, hostnames or ranges that are allowed to send HTTP PURGE requests to Varnish, to clear caches. Ranges need their IP components quoted with \" | hostname/IP/IP Range | \"172.0.0.0\"/8,\"10.0.0.0\"/8
MAGENTO_USE_SEPARATE_ADMIN_CONTAINER | Should a separate admin container be used for requests to /admin ? | true/false | false
MAGENTO_ADMIN_FRONTNAME_REGEX_ESCAPED | If MAGENTO_USE_SEPARATE_ADMIN_CONTAINER is true, the admin URL "front name" that is configured for the magento application. Please escape any regular expression special characters | regex escaped string | admin
MAGENTO_ADMIN_BACKEND_HOST | If MAGENTO_USE_SEPARATE_ADMIN_CONTAINER is true, the hostname/IP to send admin traffic to. | hostname/IP | admin
MAGENTO_ADMIN_BACKEND_PORT | If MAGENTO_USE_SEPARATE_ADMIN_CONTAINER is true, the port to send admin traffic to. | 1-65535 | 80
MAGENTO_USE_ADMIN_CONTAINER_FOR_MEDIA | If MAGENTO_USE_SEPARATE_ADMIN_CONTAINER is true, should the admin container be used to serve /media/* requests | true/false | false
MAGENTO_MAX_EXECUTION_TIME | Time in seconds to allow for the backend to respond before returning a 503 response. We recommend setting this to the PHP_MAX_EXECUTION_TIME from the web container if set + 1 second | integer (seconds) | 61
MAGENTO_ADMIN_MAX_EXECUTION_TIME | Time in seconds to allow for the admin backend to respond before returning a 503 response. We recommend setting this to the PHP_MAX_EXECUTION_TIME from the web container if set + 1 second | integer (seconds) | 61

### More information
As for all images based on the ubuntu base image, see
[the base image README](../../ubuntu/16.04/README.md)
