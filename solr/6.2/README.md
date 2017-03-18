# Solr 6

In a docker-compose.yml:
```yml
version: '3'
services:
  solr:
    image: quay.io/continuouspipe/solr6:stable
```

In a Dockerfile:
```Dockerfile
FROM quay.io/continuouspipe/solr6:stable
```

## How to build
```bash
docker-compose build --pull solr_6_2
docker-compose push solr_6_2
```

## How to use

As this is based off of an official solr image, please see their README, here:
https://hub.docker.com/_/solr/
