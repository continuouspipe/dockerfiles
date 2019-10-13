# Mailcatcher

In a docker-compose.yml:
```
version: '3'
services:
  mailcatcher:
    image: quay.io/continuouspipe/mailcatcher:latest
    extra_hosts:
      - "mailcatcher:127.0.0.1"
    expose:
      - 1025
    ports:
      - "1080:1080"
```

In a Dockerfile:
```Dockerfile
FROM quay.io/continuouspipe/mailcatcher:latest
```

## How to build:

```bash
docker-compose build mailcatcher
docker-compose push mailcatcher
```

## About

This is a Docker image that provides the Mailcatcher service, which can catch outgoing mail before
it hits the external network. It also provides a useful web interface for reviewing caught mail.

## How to use

- Port 1025 is where mail should be relayed to (SMTP).
- Port 1080 is where you can visit the UI.

In the case of Symfony application place the following configuration in `parameters.yml`:

```
mailer_transport: smtp
mailer_host: mailcatcher
mailer_user: null
mailer_password: null
mailer_sender_mail: some@example.com
mailer_port: 1025
mailer_encryption: null
```

The following variables are supported:

Variable | Description | Expected values | Default
--- | --- | --- | ----
HTTP_HOST_PORT | The port to make the Mailcatcher UI available on | 1-65535 | 1080
SMTP_HOST_PORT | The port to make the SMTP server available on. | 1-65535 | 1025
