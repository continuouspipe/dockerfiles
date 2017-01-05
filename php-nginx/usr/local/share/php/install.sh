#!/bin/bash

function do_https_certificates() {
    if [ "${WEB_HTTPS}" == "false" ]; then
        return 0
    fi
    if [ "${WEB_HTTPS_OFFLOADED}" == "true" ]; then
        return 0
    fi

    echo "Loading HTTPS Certificates..."

    if [ ! -e "${WEB_SSL_FULLCHAIN}" ] && [ ! -e "${WEB_SSL_PRIVKEY}" ]; then
        echo "Generating self-signed HTTPS Certificates..."

        mkdir -p "$(dirname "${WEB_SSL_FULLCHAIN}")" "$(dirname "${WEB_SSL_PRIVKEY}")"

        openssl req \
            -x509 \
            -nodes \
            -days 365 \
            -newkey rsa:2048 \
            -keyout "${WEB_SSL_PRIVKEY}" \
            -out "${WEB_SSL_FULLCHAIN}" \
            -subj "/C=SS/ST=SS/L=SelfSignedCity/O=SelfSignedOrg/CN=${WEB_HOST}"
    elif [ -e "${WEB_SSL_PRIVKEY}" ] && [ -e "${WEB_SSL_FULLCHAIN}" ]; then
        echo "Using provided HTTPS Certificates..."
    else
        if [ ! -e "${WEB_SSL_FULLCHAIN}" ]; then
            echo "ERROR: "
            echo "  The SSL private key ${WEB_SSL_PRIVKEY} exists but no fullchain file ${WEB_SSL_FULLCHAIN}"
            exit 1
        else
            echo "ERROR: "
            echo "  The SSL fullchain file ${WEB_SSL_FULLCHAIN} exists but no private key ${WEB_SSL_PRIVKEY}"
            exit 1
        fi
    fi
}

do_https_certificates
