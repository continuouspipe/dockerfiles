# Drupal 8: Solr 6.2

In a docker-compose.yml:
```yml
version: '3'
services:
  solr:
    image: quay.io/continuouspipe/drupal8-solr6:latest
    volumes:
      - solr_data:/usr/local/share/solr/d8/data/

volumes:
  solr_data:
    driver: local
    driver_opts:
      type: tmpfs
      device: tmpfs
      o: size=100m,uid=1000
```

```Dockerfile
FROM quay.io/continuouspipe/drupal8-solr6:latest
```

## How to build
```bash
docker-compose build drupal8_solr_6_2
docker-compose push drupal8_solr_6_2
```

## About

This is a Docker image that provides a Solr 6 search service that has been configured for use with the Drupal 8 module, https://www.drupal.org/project/search_api_solr .

## How to use

We automatically configure a "d8" solr core, which is passed in as the SOLR_CORE_NAME variable.
The config was fetched from https://www.drupal.org/project/search_api_solr on Nov 9, 2016.

As this is based off of an official solr image, please see their README, here:
https://hub.docker.com/_/solr/
