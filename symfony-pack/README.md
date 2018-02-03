# Symfony Pack

Based on [our Symfony with nginx and PHP 7.1 image](../symfony/), this Docker image is a curated Docker image for Symfony.
Its focus is purely **Developer Experience** and includes a bunch of things useful for most recent Symfony applications.

## Usage

### With Composer

If you use Symfony 4 (with Symfony Flex), you can simply use our recipe. 
The easiest way you have is to install ContinuousPipe's pack via Composer:

```yaml
composer req continuous-pipe/symfony-pack
```

The Flex recipe will create the `Dockerfile` and `docker-compose.yml` files for you. Then, you just have to get started:
```
docker-compose up
```

### Manually

You can also the base image by creating the `Dockerfile` by yourself:

```Dockerfile
# Dockerfile
FROM quay.io/continuouspipe/symfony-pack:latest

COPY . /app/

RUN container build
```
