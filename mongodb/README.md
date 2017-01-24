# MongoDB 3.4

```Dockerfile
FROM quay.io/continuouspipe/mongodb3.4:stable
```

## How to build
```bash
./build.sh
docker-compose build mongodb34
docker-compose push mongodb34
```

## How to use

As this is based on the library MySQL image, see their README on [The Docker Hub](https://hub.docker.com/_/mysql/).
