# Apache Kafka

Dockerfile for Apache Kafka.

## How to build

```bash
$ docker build .
```

## How to use

```bash
$ # Kafka is 9092, Zookeeper is 2181
$ docker run -p 2181:2181 -p 9092:9092 --env ADVERTISED_HOST=`docker-machine ip \`docker-machine active\``--env ADVERTISED_PORT=9092 continuouspipe/kafka
```

## About

Dockerfile for Apache Kafka originally based upon an image created by Spotify.
