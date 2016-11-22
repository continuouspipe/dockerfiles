#!/bin/bash

if [ -L "$0" ] ; then
    DIR="$(dirname "$(readlink -f "$0")")" ;
else
    DIR="$(dirname "$0")" ;
fi ;

(cd "$DIR" && docker-compose pull)
(cd "$DIR" && docker-compose build --force-rm)
