# Ubuntu Base

```Dockerfile
FROM quay.io/continuouspipe/nginx:7.0
```

## How to build
```bash
docker build --pull --tag quay.io/continuouspipe/nginx:7.0 --rm .
docker push
```

## How to use

Add the supervisor configuration of the service(s) you want to use in the `/etc/supervisor/conf.d` folder.

And the [confd](https://github.com/kelseyhightower/confd) configuration in `/etc/confd/conf.d` folder and the according
template in the `/etc/confd/templates` folder.
