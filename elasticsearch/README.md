# Elasticsearch 1.7/2.4/5.5/5.6

In a docker-compose.yml for 5.6:
```yml
version: '3'
services:
  elasticsearch:
    image: quay.io/continuouspipe/elasticsearch5.6:latest
```

In a docker-compose.yml for 5.5:
```yml
version: '3'
services:
  elasticsearch:
    image: quay.io/continuouspipe/elasticsearch5.5:latest
```
or 2.4:
```yml
version: '3'
services:
  elasticsearch:
    image: quay.io/continuouspipe/elasticsearch2.4:latest
```
or 1.7:
```yml
version: '3'
services:
  elasticsearch:
    image: quay.io/continuouspipe/elasticsearch1.7:latest
```

In a Dockerfile for 5.6:
```Dockerfile
FROM quay.io/continuouspipe/elasticsearch5.6:latest
```
or 5.5:
```Dockerfile
FROM quay.io/continuouspipe/elasticsearch5.5:latest
```
or 2.4:
```Dockerfile
FROM quay.io/continuouspipe/elasticsearch2.4:latest
```
or 1.7:
```Dockerfile
FROM quay.io/continuouspipe/elasticsearch1.7:latest
```

## How to build
```bash
docker-compose build --pull elasticsearch56 elasticsearch55 elasticsearch24 elasticsearch17
docker-compose push elasticsearch56 elasticsearch55 elasticsearch24 elasticsearch17
```

## About

This is a Docker image that provides an Elasticsearch service that tracks the upstream Elasticsearch image.

## How to use

### 5.6 and above
As this is based on the official Elasticsearch image, see their README on [Elastic.co](https://www.elastic.co/guide/en/elasticsearch/reference/5.6/docker.html).
This image is Centos based.

### 5.5 and below
As this is based on the library Elasticsearch image, see their README on [The Docker Hub](https://hub.docker.com/_/elasticsearch/).
This image is Debian based.
