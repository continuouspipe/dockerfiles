# SSH forward

In a docker-compose.yml:
```yml
version: '3'
services:
  sshforward:
    image: quay.io/continuouspipe/ssh-forward:latest
    environment:
      SSH_FORWARD_PASSWORD: forward
      SSH_AUTHORIZED_KEYS: "ssh-rsa AAA..."
```

In a Dockerfile:
```Dockerfile
FROM quay.io/continuouspipe/ssh-forward:latest
```

## How to build
```bash
docker-compose build ssh_forward
docker-compose push ssh_forward
```

## About

This is a Docker image to use for ssh port forwarding. For instance in order to
run Selenium Webdriver locally while running Behat on the docker container, or
for PHP XDebug remote debugging

Note: it's not recommended to expose this container's ssh port to the public
internet. Local docker development it's ok to expose it to the host's localhost.
Kubernetes has local port forwarding that can expose the SSH port from a cluster to localhost.

## How to use

### Environment variables

The following variables are supported

Variable | Description | Expected values | Default
--- | --- | --- | ----
SSH_FORWARD_PASSWORD | Sets a password for the 'forward' user for use with SSH with password authentication | password | unset
SSH_AUTHORIZED_KEYS | Sets the authorized ssh keys for the 'forward' user for use with  SSH with public key authentication | line-delimited ssh public keys | unset

## Examples

### Remote port forwarding a local selenium Webdriver service on port 4444

If via CP, get access to the sshforward port locally

```bash
cp-remote forward -s sshforward 2222:22
```

If via local Docker, this assumes you've exposed port 22 to localhost:2222

Next:

Remote port forward localhost:4444

```
ssh -p 2222 forward@localhost -N -R 4444:localhost:4444
```

Add a behat profile extending default to behat.yml:

```
sshforward:
  extensions:
    Behat\MinkExtension:
      selenium2:
        wd_host: http://sshforward:4444/wd/hub
```

Run behat

### SOCKS proxy into a K8S cluster or Docker for Mac/Windows

If via CP, get access to the sshforward port locally

```bash
cp-remote forward -s sshforward 2222:22
```

If via Docker for Mac/Windows, this assumes you've exposed port sshforward:22 to localhost:2222

Next:

Set up a SSH SOCKS proxy:

```bash
ssh -p 2222 forward@localhost -N -D 1080
```

Configure your browser to use localhost:1080 as a SOCKS proxy
