# Letsencrypt / Certbot instructions

## Wildcard / asterisk ceritificate

~~~
sudo certbot certonly \
  --manual \
  --preferred-challenges=dns \
  --email example@mail.com \
  --server https://acme-v02.api.letsencrypt.org/directory \
  --agree-tos \
  -d example.com \
  -d *.example.com
~~~

* Explanations

  ~~~
  certonly	                Request or renew certificate without installing it
  -manual	                  Obtaining certificates
  -preferred-challenges=dns	Use DNS to authenticate as domain owner
  -server	                  Server, which should be used for the generation of the certificates
  -agree-tos	              Agree with the terms and conditions of the ACME server
  -d	                      Domain for which a certificate is to be created
  ~~~
