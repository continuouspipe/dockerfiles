# Piwik

In a docker-compose.yml:
```yml
version: '3'
services:
  piwik:
    image: quay.io/continuouspipe/piwik-php7.1-apache:latest
```

In a Dockerfile:
```Dockerfile
FROM quay.io/continuouspipe/piwik-php7.1-apache:latest
```

## How to build
```bash
docker-compose build piwik_php71_apache
docker-compose push piwik_php71_apache
```

## About

This is an image that installs [piwik](http://piwik.org) web analytics software.


### Environment variables

No additional environment variables over those of continuouspipe/php7.1-apache are supported, as piwik at this time does not support headless installations.


