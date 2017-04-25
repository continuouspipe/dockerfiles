#!/bin/bash

echo "$(echo "$SSL_CERT" | base64 -d)" > /etc/nginx/default-certificate.pem
echo >> /etc/nginx/default-certificate.pem
echo "$(echo "$SSL_KEY" | base64 -d)" >> /etc/nginx/default-certificate.pem

export SSL_SHA1SUM="$(sha1sum /etc/nginx/default-certificate.pem)"

exec /nginx-ingress-controller $@
