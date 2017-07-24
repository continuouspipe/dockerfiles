#!/bin/bash

source /usr/local/share/symfony/symfony_functions.sh

do_symfony_flex_build() {
  do_symfony_flex_encore_assets
}

do_symfony_flex_encore_assets() {
  if [ -f "yarn.lock" ]; then
    yarn install

    if grep -q "symfony/webpack-encore" yarn.lock; then
      npx encore production
    fi
  fi
}

do_migrate() {
  if [ ! -f "$SYMFONY_CONSOLE" ]; then
    echo "No console, will not run migrations"
    return
  fi

  HAS_DOCTRINE_MIGRATIONS=`has_package doctrine/doctrine-migrations-bundle`
  if [ "$HAS_DOCTRINE_MIGRATIONS" = "true" ]; then
    do_symfony_console doctrine:migrations:migrate
  fi

  HAS_DOCTRINE_ORM=`has_package doctrine/orm`
  if [ "$HAS_DOCTRINE_ORM" = "true" ]; then
    do_symfony_console doctrine:schema:update --force
  fi 
}

has_package() {
  if [ ! -f "composer.lock" ]; then
    return
  fi

  jq -c '.packages[] | select(.name == "'$1'") | has("name")' composer.lock
}
