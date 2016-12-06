# Hem, for Ruby and Existing Helper Tasks

```Dockerfile
FROM quay.io/continuouspipe/hem:latest
```

## How to build
```bash
docker build --pull --tag quay.io/continuouspipe/hem:latest --rm .
docker push
```

## How to use

As for all images based on the ubuntu base image, see
[the base image README](../../ubuntu/16.04/README.md)

Provide the following variables to be able to synchronise assets from AWS:

- AWS_ACCESS_KEY_ID
- AWS_SECRET_ACCESS_KEY

You should also provide the hem project configuration, through use of a volume
or a sub-image: `/app/tools/hem/config.yaml`. This will direct hem to the right
assets in S3.
