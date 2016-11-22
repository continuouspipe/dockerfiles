# SOLR

```Dockerfile
FROM quay.io/continuouspipe/solr:6.2
```

## How to build
```bash
docker build --pull --tag quay.io/continuouspipe/solr:6.2 --rm .
docker push
```

## How to use

As this is based off of an official solr image, please see their README, here:
https://hub.docker.com/_/solr/
