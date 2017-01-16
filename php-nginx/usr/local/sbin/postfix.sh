#!/bin/bash
# call "postfix stop" when exiting
trap "{ echo Stopping Postfix; /usr/sbin/postfix stop; exit 0; }" EXIT

source /etc/sysconfig/network

/usr/libexec/postfix/aliasesdb
/usr/libexec/postfix/chroot-update

if [ -n "${POSTFIX_RELAY_USER}" ]; then
  postmap /etc/postfix/sasl_passwd
fi

# start postfix
/usr/sbin/postfix - c /etc/postfix start

# avoid exiting
sleep infinity
