#!/bin/bash

echo "$SSL_CERT" | base64 -d > /etc/nginx/default-certificate.pem
echo >> /etc/nginx/default-certificate.pem
echo "$SSL_KEY" | base64 -d >> /etc/nginx/default-certificate.pem

SSL_SHA1SUM="$(sha1sum /etc/nginx/default-certificate.pem)"
export SSL_SHA1SUM

exec /nginx-ingress-controller "$@"
