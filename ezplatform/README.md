# eZ 6

In a Dockerfile:
```Dockerfile
FROM quay.io/continuouspipe/ez6-apache-php7:latest

COPY . /app

ARG GITHUB_TOKEN=

RUN container build
```

## How to build

```bash
docker-compose build ez
docker-compose push ez
```

## About

This is a Docker image that can serve an eZ website via Apache and PHP 7.0

## How to use

### Configuration

Declare the following file in `app/config/parameters.php`:

```php
<?php
$parameters = array_filter([
    'database_host' => getenv('DATABASE_HOST'),
    'database_name' => getenv('DATABASE_NAME'),
    'database_user' => getenv('DATABASE_USER'),
    'database_password' => getenv('DATABASE_PASSWORD'),
    'secret' => getenv('SYMFONY_SECRET')
]);
foreach ($parameters as $key => $value) {
    $container->setParameter($key, $value);
}
```

Then add the following to the imports section of `app/config/config.yml`:
```yaml
- { resource: parameters.php }
```

### Composer Post-install

As we run composer in the "do_build()" step during image build, it's possible that eZ will generate some cache files
in `app/cache/`.

PHP picks up docker image layers as being different filesystems, so cache clearing/warmup tries to do a rename() operation
when it should be trying to move. Therefore, we need to clear cache in the same image layer as it is generated in.

To fix this, add the following to the bottom of the "scripts -> build" section in `composer.json`:
```
"eZ\\Bundle\\EzPublishCoreBundle\\Composer\\ScriptHandler::clearCache"
```

### Environment variables

The following variables are supported

Variable | Description | Expected values | Default
--- | --- | --- | ----
EZPLATFORM_INSTALL_PROFILE | The install profile to install eZ with | string | clean
DATABASE_HOST | The database server hostname/IP address to find the database on. | string | database
DATABASE_NAME | The name of the database on the database server | string | ez
DATABASE_USER | The username to connect to the database server with | string | ez
DATABASE_PASSWORD | The password of the DATABASE_USER | string | PleaseChangeMeToBeASecurePassword
SYMFONY_SECRET | The secret to be used with symfony | string | PleaseChangeMeToBeASecureSecretString

### More details

This image is based on the Symfony one, available [here](../../symfony/)
