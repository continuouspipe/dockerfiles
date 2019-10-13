# Postgres 9.4 and 9.6

For Postgres 9.6 in a docker-compose.yml:
```yml
version: '3'
services:
  database:
    image: quay.io/continuouspipe/postgres9.6:latest
    expose:
      - 5432
    environment:
      POSTGRES_USER: user
      POSTGRES_PASSWORD: password
      POSTGRES_DB: database_name
    ports:
      - "5432:5432"
```

or in a Dockerfile:
```Dockerfile
FROM quay.io/continuouspipe/postgres9.6:latest
```

For Postgres 9.4 in a docker-compose.yml:
```yml
version: '3'
services:
  database:
    image: quay.io/continuouspipe/postgres9.4:latest
    expose:
      - 5432
    environment:
      POSTGRES_USER: user
      POSTGRES_PASSWORD: password
      POSTGRES_DB: database_name
    ports:
      - "5432:5432"
```

or in a Dockerfile:
```Dockerfile
FROM quay.io/continuouspipe/postgres9.4:latest
```

## How to build
```bash
./build.sh
docker-compose build --pull postgres94 postgres96
docker-compose push postgres94 postgres96
```

## About

This is a Docker image for Postgres which tracks the upstream official image.

## How to use

As this is based on the library Postgres image, see their README on
[The Docker Hub](https://hub.docker.com/_/postgres/).
