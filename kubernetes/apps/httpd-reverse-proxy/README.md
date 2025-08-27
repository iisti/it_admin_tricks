# Apache2 / httpd reverse proxy configuration for Kubernetes

## httpd reverse proxy with LDAPS Authentication

**NOTICE**: Traefik was used as an ingress controller.

1. Change the properties in the yaml to fit your use case.
1. Deploy the [httpd-reverse-proxy-with-ldaps.yaml](httpd-reverse-proxy-with-ldaps.yaml) manifest with command below.

    ~~~sh
    kubectl -n httpd-test apply -f httpd-reverse-proxy-with-ldaps.yaml
    ~~~

1. One can test ldap with [ldap.md](../../linux/ldap.md)

## httpd reverse proxy with Oauth 2.0 Authentication

**NOTICE**: Traefik was used as an ingress controller.

1. Change the properties in the yaml to fit your use case.
1. Deploy the [httpd-reverse-proxy-with-oauth2.yaml](httpd-reverse-proxy-with-oauth2.yaml) manifest with command below.

    ~~~sh
    kubectl -n httpd-test apply -f httpd-reverse-proxy-with-oauth2.yaml
    ~~~

1. Login with <https://domain.example.com/> (or URL which was configured)
1. Logout with <https://domain.example.com/logout>
