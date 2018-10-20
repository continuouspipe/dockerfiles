# ContinuousPipe Dockerfiles

The purpose of this repository is to store all the ContinuousPipe's Docker images. These images are used for
internal services and for the application templates.

## Images

### Compiled Applications

- [Scala](scala-base/1.0/)

### Javascript Applications

- [NodeJS](nodejs/)

### PHP Applications

- *Drupal 7 or 8*
    - [Apache w/ PHP 5.6/7.0/7.1](drupal/)
    - [Solr 4.10](drupal8-solr/4.10/)
    - [Solr 6.2](drupal8-solr/6.2/)
    - [Varnish 4.0](drupal8-varnish/4.0/)
- [eZ Platform 6.x](ez/6.x/)
- *General PHP*
    - [Apache w/ PHP (5.6, 7.0, 7.1)](php/apache/)
    - [NGINX w/ PHP-FPM (5.6, 7.0, 7.1)](php/nginx/)
- [Magento 1](magento1/)
- *Magento 2*
    - [NGINX w/ PHP-FPM 7.0](magento2/)
    - [Varnish](magento2-varnish/4.0/)
- [Symfony - NGINX or Apache with PHP 5.6, 7.0 or 7.1)](symfony/)
- [Piwik](piwik/)

### Web Applications

- [NGINX](nginx/)

### Supporting Services

Caches:
- [Memcached](memcached/)
- [Redis 3.2](redis/3.2/)
- [Varnish](varnish/)

Databases:
- [MongoDB](mongodb/)
- [MySQL 5.6, 5.7, 8.0](mysql/)

Search:
- [Elasticsearch](elasticsearch/)
- [Solr 4.10](solr/4.10/)
- [Solr 6.2](solr/6.2/)

Other:
- [Hem](hem/)
- [Mailcatcher](mailcatcher/)
- [NGINX Reverse Proxy](nginx-reverse-proxy/)
- [SSH Forwarding](ssh-forward/)

### Bases

- [Ubuntu 16.04](ubuntu/16.04/)

## Testing

We try to follow best practises when creating shell scripts and Dockerfiles.

To help aim for this, we use the following tools:
* [shellcheck](https://github.com/koalaman/shellcheck) - checks syntax and best practises for shell scripts
* [hadolint](https://github.com/lukasmartinelli/hadolint) - checks syntax and best practises for Dockerfiles
* [BATS](https://github.com/sstephenson/bats) - unit tests for bash scripts
* Integration tests using docker-compose and shell scripts

To run all of these tools, you can use the helper script in the project root:
```bash
bash test.sh
```
