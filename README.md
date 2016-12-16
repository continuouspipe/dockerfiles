# ContinuousPipe Dockerfiles

The purpose of this repository is to store all the ContinuousPipe's Docker images. These images are used for
internal services and for the application templates.

## Images

### Application-centric

- [Magento2 (nginx & php-fpm 7.0)](magento2-nginx/fpm-7.0)
- [eZ Platform 6.x](ez/6.x/)
- *Drupal 8*
    - [Apache w/ PHP 7.0](drupal8-apache/7.0)
    - [Varnish 4.0](drupal8-varnish/4.0/)
    - [Solr 4.10](drupal8-solr/4.10/)
    - [Solr 6.2](drupal8-solr/6.2/)

### Bases

- [Ubuntu 16.04](ubuntu/16.04/)
- [Solr 4.10](solr/4.10/)
- [Solr 6.2](solr/6.2/)
- [Redis 3.2](redis/3.2/)
- [MySQL 5.6](mysql/5.6/)
- [Apache w/ PHP](php-apache/)
- [NGINX w/ PHP-FPM](php-nginx/)

## Testing

We try to follow best practises when creating shell scripts and Dockerfiles.

To run the best practise checkers, install [shellcheck](https://github.com/koalaman/shellcheck) and
[hadolint](https://github.com/lukasmartinelli/hadolint) then run:

```bash
bash test.sh
```

This run shellcheck for every script found and hadolint for every Dockerfile.
