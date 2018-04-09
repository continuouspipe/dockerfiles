#!/bin/bash

function dhparam_generate() (
    umask 0077
    # shellcheck disable=SC2046
    openssl dhparam $([ "${WEB_SSL_DHPARAM_TYPE,,}" != dsa ] || echo '-dsaparam') \
        -out "${WEB_SSL_DHPARAM_FILE}" "${WEB_SSL_DHPARAM_SIZE}"
)

function do_dhparam_regenerate() {
    if is_true "$DEBUG"; then
       dhparam_generate
    else 
       dhparam_generate 2>/dev/null
    fi

    if is_true "$START_WEB" && [ -e /var/run/supervisor.sock ]; then
       do_webserver_reload
    fi
}

function do_https_certificates() {
    if [ "${WEB_HTTPS}" == "false" ]; then
        return 0
    fi
    if [ "${WEB_HTTPS_OFFLOADED}" == "true" ]; then
        return 0
    fi

    if is_true "$WEB_SSL_DHPARAM_ENABLE" && [ ! -e "${WEB_SSL_DHPARAM_FILE}" ]; then
        echo "Generating DH parameters..."

        dhparam_generate
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

do_webserver() {
  do_https_certificates
}
