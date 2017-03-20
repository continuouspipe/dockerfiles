#!/bin/bash

do_spryker_directory_create() {
  mkdir -p /app/data/DE/cache/Yves/twig
  mkdir -p /app/data/DE/cache/Zed/twig
  mkdir -p /app/data/DE/logs
  mkdir -p /app/data/common
}

do_spryker_config_create() {
  # create .pgpass in home directory for postgres client
  echo "$DATABASE_HOST:*:*:$DATABASE_USER:$DATABASE_PASSWORD" > ~/.pgpass
  chmod 0600 ~/.pgpass
}

do_spryker_build() {
  do_spryker_directory_create
  do_spryker_config_create
}
