# SOLR

```Dockerfile
FROM quay.io/continuouspipe/drupal8-solr:4.10_v2
```

## How to build
```bash
docker build --pull --tag quay.io/continuouspipe/drupal8-solr:4.10_v2 --rm .
docker push
```

## How to use

As this is based off of a semi-official solr image, please see their README, here:
https://hub.docker.com/r/makuk66/docker-solr/builds/bxsjvchebmrgdmbtjabbta3/

We are also based off of a parent image within this repository. Check out [the solr 4.10 image](../../solr/4.10).
