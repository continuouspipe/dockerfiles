# MySQL 5.6

```Dockerfile
FROM quay.io/inviqa_images/mysql:5.6
```

## How to build
```bash
docker build --pull --tag quay.io/inviqa_images/mysql:5.6 --rm .
docker push
```

## How to use

As this is based on the library MySQL image, see their README on [The Docker Hub](https://hub.docker.com/_/mysql/).
