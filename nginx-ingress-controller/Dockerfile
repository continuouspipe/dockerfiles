FROM quay.io/aledbf/nginx-ingress-controller:0.85

MAINTAINER "Kieren Evans <kevans+nginx-ingress-controller@inviqa.com>"

COPY ./etc/ /etc/
COPY ./usr/ /usr/

ENV SSL_CERT= \
    SSL_KEY=

CMD ["/usr/local/bin/boot.sh"]
