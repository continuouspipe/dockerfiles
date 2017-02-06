# MySQL 8.0

```Dockerfile
FROM quay.io/continuouspipe/mysql8.0:stable
```

# MySQL 5.7

```Dockerfile
FROM quay.io/continuouspipe/mysql5.7:stable
```

# MySQL 5.6

```Dockerfile
FROM quay.io/continuouspipe/mysql5.6:stable
```

## How to build
```bash
./build.sh
docker-compose build mysql56 mysql57 mysql80
docker-compose push mysql56 mysql57 mysql80
```

## How to use

As this is based on the library MySQL image, see their README on [The Docker Hub](https://hub.docker.com/_/mysql/).

In addition to this, the following variables are supported:

Variable | Description | Expected values | Default
--- | --- | --- | ----
MYSQL_DATABASE_GRANT | The database pattern to grant for the MYSQL_USER | a database pattern match | not set
