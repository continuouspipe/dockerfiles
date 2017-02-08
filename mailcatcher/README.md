# Mailcatcher

```Dockerfile
FROM quay.io/continuouspipe/mailcatcher:stable
```

Port 1025 is where mail should be relayed to
Port 1080 is where you can visit the UI

Example `docker-compose` configuration:

```
mailcatcher:
    image: quay.io/continuouspipe/mailcatcher:stable
    extra_hosts:
        - "mailcatcher:127.0.0.1"
    expose:
        - 25
    ports:
        - "1080:80"
```

_Note: the Mailcatcher ports are 25 (SMTP) and 80 (web interface)._

Then in `parameters.yml` (in case of Symfony application):

```
mailer_transport: smtp
    mailer_host: mailcatcher
    mailer_user: null
    mailer_password: null
    mailer_sender_mail: some@email.com
    mailer_port: 25
    mailer_encryption: null
```
