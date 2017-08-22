FROM gcr.io/google-containers/nginx-ingress-controller:0.9.0-beta.5

MAINTAINER "Kieren Evans <kevans+nginx-ingress-controller@inviqa.com>"

COPY ./shared/ /

ENV SSL_CERT= \
    SSL_KEY=

CMD ["/usr/local/bin/boot.sh"]
