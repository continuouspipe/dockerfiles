# Nginx Ingress Controller

For how to deploy this image, please see https://github.com/continuouspipe/nginx-ingress-controller/

## About

This builds off of the 0.9.0.beta3 version of https://github.com/kubernetes/ingress/tree/master/controllers/nginx.

The Beta3 NGINX ingress controller does not open up port 443 if the deployed ingress does not have a TLS section in it's spec, with a hostname and a reference to an SSL certificate that matches the hostname.

This is a bit too restrictive for our purposes, as we wish to have 443 opened for most sites with a valid wildcard SSL certificate present.

This would be possible if an ingress that supported TLS were to sit in front of the nginx ingress controller, however this seems to stop the "--publish-service" flag from updating the status of the deployed services to match the external IP address.

So, we have taken the decision to customise the NGINX template to allow port 443 to be open for all deployed sites that use the NGINX ingress controller.

1. If a TLS section is provided with a valid (or self signed) certificate, the existing NGINX ingress controller is maintained - http and https endpoints will be available, where https is using the provided certificate.
2. If no TLS section is provided, the new functionality kick in and the default SSL certificate will be used to serve traffic over port 443 instead.

Depending on the secure-backends annotation, internal communications from the NGINX ingress controller to the deployed service will be to port 80 if false, or 443 if true.

Both http and https traffic will be forwarded to a single port, so ensure you detect `X-Forwarded-Proto` in your deployed service and redirect the user to the right port.

NOTE:
A bug that we hope to solve later is that if you use the default SSL certificate with port 443 being talked to internally,
the NGINX ingress controller tries to talk to the HTTPS port with the HTTP protocol, causing an error.
