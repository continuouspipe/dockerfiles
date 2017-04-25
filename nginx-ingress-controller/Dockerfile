FROM quay.io/aledbf/nginx-ingress-controller:0.85

MAINTAINER "Kieren Evans <kevans+nginx-ingress-controller@inviqa.com>"

COPY nginx.tmpl /etc/nginx/template/nginx.tmpl
COPY boot.sh /usr/local/bin/boot.sh

ENV SSL_CERT= \
    SSL_KEY=

CMD ["/usr/local/bin/boot.sh"]
