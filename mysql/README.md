# MySQL 8.0

In a docker-compose.yml:
```yml
version: '3'
services:
  database:
    image: quay.io/continuouspipe/mysql8.0:latest
    environment:
      MYSQL_ROOT_PASSWORD: "a secret mysql root password"
      MYSQL_DATABASE: my_database
      MYSQL_USER: my_user
      MYSQL_PASSWORD: "a secret password for my_user"
```

In a Dockerfile:
```Dockerfile
FROM quay.io/continuouspipe/mysql8.0:latest
```

# MySQL 5.7

In a Dockerfile:
```Dockerfile
FROM quay.io/continuouspipe/mysql5.7:latest
```
In docker-compose.yml:
```yml
version: '3'
services:
  database:
    image: quay.io/continuouspipe/mysql5.7:latest
    environment:
      MYSQL_ROOT_PASSWORD: "a secret mysql root password"
      MYSQL_DATABASE: my_database
      MYSQL_USER: my_user
      MYSQL_PASSWORD: "a secret password for my_user"
```

# MySQL 5.6

In a Dockerfile:
```Dockerfile
FROM quay.io/continuouspipe/mysql5.6:latest
```
In docker-compose.yml:
```yml
version: '3'
services:
  database:
    image: quay.io/continuouspipe/mysql5.6:latest
    environment:
      MYSQL_ROOT_PASSWORD: "a secret mysql root password"
      MYSQL_DATABASE: my_database
      MYSQL_USER: my_user
      MYSQL_PASSWORD: "a secret password for my_user"
```

## How to build
```bash
./build.sh
docker-compose build --pull mysql56 mysql57 mysql80
docker-compose push mysql56 mysql57 mysql80
```

## About

This is set of Docker images for MySQL which track the upstream official MySQL images.

## How to use

As this is based on the library MySQL image, see their README on [The Docker Hub](https://hub.docker.com/_/mysql/).

In addition to this, the following variables are supported:

Variable | Description | Expected values | Default
--- | --- | --- | ----
MYSQL_DATABASE_GRANT | The database pattern to grant for the MYSQL_USER | a database pattern match | not set
