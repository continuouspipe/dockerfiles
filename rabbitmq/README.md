# RabbitMQ
Includes the management plugin which is available on the port `15672`
## Usage
### docker-compose
```
version: '3'
services:
  rabbitmq:
    image: "quay.io/continuouspipe/rabbitmq37-management:latest"
    # image: "quay.io/continuouspipe/rabbitmq36-management:latest"
    hostname: "rabbitmq"
    environment:
      RABBITMQ_ERLANG_COOKIE: "SAMPLE"
      RABBITMQ_DEFAULT_USER: "rabbitmq"
      RABBITMQ_DEFAULT_PASS: "rabbitmq"
      RABBITMQ_DEFAULT_VHOST: "/"
    # Please define ports in your docker-compose.override.yml
    # ports:
    #  - "15672:15672"
    #  - "5672:5672"

```
### Dockerfile
```
FROM quay.io/continuouspipe/rabbitmq37-management:latest
```
or
```
FROM quay.io/continuouspipe/rabbitmq36-management:latest
```
