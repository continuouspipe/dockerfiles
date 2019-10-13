# Hem, for Ruby and Existing Helper Tasks

In a docker-compose.yml:
```yml
version: '3'
services:
  hem:
    image: quay.io/continuouspipe/hem1:latest
    environment:
      AWS_ACCESS_KEY_ID: "An AWS User ID that should remain secret!"
      AWS_SECRET_ACCESS_KEY: "An AWS Secret Key that should remain secret!"
```

In a Dockerfile:
```Dockerfile
FROM quay.io/continuouspipe/hem:latest

ARG AWS_ACCESS_KEY_ID=
ARG AWS_SECRET_ACCESS_KEY=

RUN container build
```

## How to build
```bash
docker-compose build hem
docker-compose push hem
```

## About

This is a Docker image to provide the Inviqa tool, "hem", which was originally used to manage
Vagrant VMs and run installation steps on a started VM.

Now, hem can be used fetch database dumps and assets from AWS and run the custom tasks that have built up over the years.

## How to use

As for all images based on the ubuntu base image, see
[the base image README](../../ubuntu/16.04/README.md)
