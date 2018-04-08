#!/bin/bash
docker-compose config | grep -E '^\s\s\w+:' | grep -v '  external_' | sed -E 's/  (.+):/    | \1 |/g'
