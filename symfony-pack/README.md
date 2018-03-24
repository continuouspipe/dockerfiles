# Symfony Pack

Based on [our Symfony with nginx and PHP 7.1 image](../symfony/), this Docker image is a curated Docker image for Symfony.
Its focus is purely **Developer Experience** and includes a bunch of things useful for most recent Symfony applications.

## Usage

### With Docker Generator

Checkout [ContinuousPipe's Docker Generator for Symfony](https://github.com/continuouspipe/flex). It's the easiest way
to get your Docker configuration going for your Symfony project.

### Manually

You can also the base image by creating the `Dockerfile` by yourself:

```Dockerfile
# Dockerfile
FROM quay.io/continuouspipe/symfony-pack:latest

WORKDIR /app
COPY . /app/

RUN container build
```
