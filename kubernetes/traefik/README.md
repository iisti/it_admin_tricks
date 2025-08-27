# Traefik Instructions

## How to use IPAllowList middleware with Kubernetes and Traefik

**NOTICE**: Traefik was used as an ingress controller. A Hetzner Load Balancer was used as an LB. Hetzner LBs forward `X-Forwarded-*` headers, source <https://docs.hetzner.com/cloud/load-balancers/faq#do-load-balancers-forward-special-http-headers>.

1. Set configuration
    * Source <https://doc.traefik.io/traefik/routing/entrypoints/#forwarded-headers>

    ~~~yaml
    --entryPoints.web.forwardedHeaders.insecure
    --entryPoints.websecure.forwardedHeaders.insecure
    ~~~

1. Create namespace

    ~~~sh
    kubectl create ns whoami-dev
    ~~~

1. Check that ipallowlist middleware is in use in the ingress annotations.

    ~~~yaml
    annotations:
      # whoami-dev comes from namespace name
      # ipallowlist comes from middleware name
      traefik.ingress.kubernetes.io/router.middlewares: whoami-dev-ipallowlist@kubernetescrd
    ~~~

1. Set the allowd IPs in section

    ~~~yaml
    sourceRange:
      - 123.123.123.123/32
    ~~~

1. Apply the whoami configuration

    ~~~sh
    kubectl -n whoami-dev apply -f whoami-deployment.yaml
    ~~~

1. Whoami outputs
    * When the IPAllowList middleware and Traefik's header forward are disabled, the whoami will show something similar to below.

      ~~~text
      Hostname: whoami-7986f84f5-74hj8
      IP: 127.0.0.1
      IP: ::1
      IP: 10.55.0.161
      IP: fe80::xxxx:yyyy:www:eeee
      RemoteAddr: 10.55.0.160:56704
      GET / HTTP/1.1
      Host: whoami.dev.example.com
      User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:140.0) Gecko/20100101 Firefox/140.0
      Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8
      Accept-Encoding: gzip, deflate, br, zstd
      Accept-Language: en-GB,en;q=0.5
      Dnt: 1
      Priority: u=0, i
      Sec-Fetch-Dest: document
      Sec-Fetch-Mode: navigate
      Sec-Fetch-Site: none
      Sec-Fetch-User: ?1
      Sec-Gpc: 1
      Te: trailers
      Upgrade-Insecure-Requests: 1
      X-Forwarded-For: 10.55.0.1
      X-Forwarded-Host: whoami.dev.example.com
      X-Forwarded-Port: 80
      X-Forwarded-Proto: http
      X-Forwarded-Server: traefik-6566974df8-jwdvn
      X-Real-Ip: 10.55.0.1
      ~~~

    * When Traefik's header forward is enabled, whoami will show something similar to below.

      ~~~text
      Hostname: whoami-7986f84f5-74hj8
      IP: 127.0.0.1
      IP: ::1
      IP: 10.55.0.161
      IP: fe80::xxxx:yyyy:www:eeee
      RemoteAddr: 10.55.0.163:39560
      GET / HTTP/1.1
      Host: whoami.dev.example.com
      User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:140.0) Gecko/20100101 Firefox/140.0
      Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8
      Accept-Encoding: gzip, deflate, br, zstd
      Accept-Language: en-GB,en;q=0.5
      Dnt: 1
      Priority: u=0, i
      Sec-Fetch-Dest: document
      Sec-Fetch-Mode: navigate
      Sec-Fetch-Site: none
      Sec-Fetch-User: ?1
      Sec-Gpc: 1
      Te: trailers
      Upgrade-Insecure-Requests: 1
      X-Forwarded-For: 123.123.123.123, 10.55.0.1
      X-Forwarded-Host: whoami.dev.example.com
      X-Forwarded-Port: 443
      X-Forwarded-Proto: https
      X-Forwarded-Server: traefik-795c654445-4wc9x
      X-Real-Ip: 10.55.0.1
      ~~~

## How to use BasicAuth middleware with Kubernetes and Traefik

Do same steps as in **How to use IPAllowList middleware with Kubernetes and Traefik**, but check that BasicAuth middleware is enabled in ingress resource.

~~~yaml
  annotations:
    # whoami-dev comes from namespace name
    # basic-auth-middleware comes from middleware name
    # Annotation for using basic-auth
    traefik.ingress.kubernetes.io/router.middlewares: whoami-dev-basic-auth-middleware@kubernetescrd
~~~
