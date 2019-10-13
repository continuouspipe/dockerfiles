# PhantomJS 2

In a docker-compose.yml:
```yml
version: '3'
services:
  phantomjs:
    image: quay.io/continuouspipe/phantomjs2:latest
```

In a Dockerfile:
```Dockerfile
FROM quay.io/continuouspipe/phantomjs2:latest
```

## How to build
```bash
docker-compose build phantomjs2
docker-compose push phantomjs2
```

## About

This is a Docker image that provides the PhantomJS headless browser.

## How to use

By default this will create a service running phantomjs with webdriver port 4444

Run this as a service, and expose port 4444.
