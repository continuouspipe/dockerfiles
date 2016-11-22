#!/bin/bash

pushd ubuntu/16.04
docker build -t quay.io/continuouspipe/ubuntu:16.04 .
popd

pushd php-apache/7.0
docker build -t quay.io/continuouspipe/php-apache:7.0 .
popd

pushd ez/6.x
docker build -t quay.io/continuouspipe/ez:6.x .
popd

pushd drupal8-apache/7.0
docker build -t quay.io/continuouspipe/drupal8-apache:7.0 .
popd

pushd mysql/5.6
docker build -t quay.io/continuouspipe/mysql:5.6 .
popd

pushd redis/3.2
docker build -t quay.io/continuouspipe/redis:3.2 .
popd

pushd solr/6.2
docker build -t quay.io/continuouspipe/solr:6.2 .
popd

pushd drupal8-solr/6.2
docker build -t quay.io/continuouspipe/drupal8-solr:6.2 .
popd
