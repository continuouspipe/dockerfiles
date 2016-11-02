#!/bin/sh

echo 'Dropping the Magento DB if exists'
mysql -h$DATABASE_HOST -uroot -p$DATABASE_ROOT_PASSWORD -e "DROP DATABASE IF EXISTS $DATABASE_NAME" || exit 1

echo 'Create Magento database'
echo "create database $DATABASE_NAME ; grant ALL on $DATABASE_NAME.* to $DATABASE_USER@'%' identified by '$DATABASE_PASSWORD' ; flush privileges" |  mysql -uroot -p$DATABASE_ROOT_PASSWORD -h$DATABASE_HOST

echo 'zcating the magento database dump into the database'
zcat tools/assets/development/magentodb.sql.gz | mysql -h$DATABASE_HOST -uroot -p$DATABASE_ROOT_PASSWORD $DATABASE_NAME || exit 1
