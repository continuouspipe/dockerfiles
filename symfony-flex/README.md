# Symfony Flex

```
FROM quay.io/continuouspipe/symfony-flex:latest

ARG GITHUB_TOKEN=
ARG APP_ENV=prod

COPY . /app/

RUN container build
```

## What's inside

Based on [our Symfony with nginx and PHP 7.1 image](../symfony/), this Docker image contains all you need to build most of the Symfony flex application. It adds the following to its base image:

1. *Assets managment*
   Run [Encore](http://symfony.com/doc/current/frontend.html) when building the Docker image. 

2. *Database migrations*
   Run `container migrate` and it will run the Doctrine ORM migrations. With MigrationsBundle if you have it, with the `schema:update` command if not.

