# MAGENTO 2 VARNISH

```Dockerfile
FROM quay.io/inviqa_images/drupal8-varnish:4.0_v1
```

## How to build
```bash
docker build --pull --tag quay.io/inviqa_images/drupal8-varnish:4.0_v1 --rm .
docker push
```

## How to use

As for all images based on the ubuntu base image, see
[the base image README](../../ubuntu/16.04/README.md)

We configure the varnish config file, `/etc/varnish/default.vcl` to be one from
[geerlingguy's Drupal VM](https://raw.githubusercontent.com/geerlingguy/drupal-vm/3.5.2/provisioning/templates/drupalvm.vcl.j2)
