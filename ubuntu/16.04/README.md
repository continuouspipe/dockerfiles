# Ubuntu Base

```
FROM quay.io/inviqa_images/ubuntu:16.04
```

## How to use

Add the supervisor configuration of the service(s) you want to use in the `/etc/supervisor/conf.d` folder.

And the [confd](https://github.com/kelseyhightower/confd) configuration in `/etc/confd/conf.d` folder and the according 
template in the `/etc/confd/templates` folder.

## Known child images

- [php-apache:7.0](../../php-apache/7.0)
