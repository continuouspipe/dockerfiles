# Drupal 8: Varnish

In a docker-compose.yml:
```yml
version: '3'
services:
  varnish:
    image: quay.io/continuouspipe/drupal8-varnish4:latest
    environment:
      VARNISH_SECRET: "A secret that should remain secret!"
```

In a Dockerfile:
```Dockerfile
FROM quay.io/continuouspipe/drupal8-varnish4:latest
```

## How to build
```bash
docker-compose build drupal8_varnish
docker-compose push drupal8_varnish
```

## About

This is a Docker image that provides a Varnish HTTP Cache service customised for Drupal 8.
It may work for Drupal 7 too!

## How to use

### Environment variables

The following environment variables are supported

Variable | Description | Expected values | Default
---|---|---|---
DRUPAL_CACHE_ERRORS | If "true", varnish will cache responses with HTTP Codes 404, 301 or 500 for 10 minutes to protect the web server. | true/false | true

We configure the varnish config file, `/etc/varnish/default.vcl` to be one from
[geerlingguy's Drupal VM](https://raw.githubusercontent.com/geerlingguy/drupal-vm/3.5.2/provisioning/templates/drupalvm.vcl.j2)

As for all images based on the ubuntu base image, see
[the base image README](../../ubuntu/16.04/README.md)
