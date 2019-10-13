# Solr 6

In a docker-compose.yml:
```yml
version: '3'
services:
  solr:
    image: quay.io/continuouspipe/solr6:latest
    environment:
      SOLR_CORE_NAME: example_core
    volumes:
      - solr_data:/usr/local/share/solr/example_core/data/

volumes:
  solr_data:
    driver: local
    driver_opts:
      type: tmpfs
      device: tmpfs
      o: size=100m,uid=1000
```

In a Dockerfile:
```Dockerfile
FROM quay.io/continuouspipe/solr6:latest
```

## How to build
```bash
docker-compose build --pull solr_6_2
docker-compose push solr_6_2
```

## About

This is a Docker image that provides a Solr 6 search service that tracks the upstream library image.

## How to use

As this is based off of an official solr image, please see their README, here:
https://hub.docker.com/_/solr/
