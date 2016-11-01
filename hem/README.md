# Ubuntu Base

```Dockerfile
FROM quay.io/inviqa_images/hem:latest
```

## How to build
```bash
docker build --pull --tag quay.io/inviqa_images/hem:latest --rm .
docker push
```

## How to use

Add the supervisor configuration of the service(s) you want to use in the `/etc/supervisor/conf.d` folder.

And the [confd](https://github.com/kelseyhightower/confd) configuration in `/etc/confd/conf.d` folder and the according
template in the `/etc/confd/templates` folder.
