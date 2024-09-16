# LDAP / LDAPS instructions

## Test ldap connection with Debian

1. Install ldap-utils

    ~~~sh
    apt-get update && apt-get install ldap-utils
    ~~~

1. Test connection with ldapsearch
    * The command connects with ldaptest user and searches for test.user.

        ~~~sh
        ldapsearch -x -D "CN=ldaptest,OU=Accounts,DC=domain,DC=com" \
                -W -H ldaps://ldap.example-domain.com \
                -b 'OU=Internal,OU=Accounts,DC=domain,DC=com' \
                -s sub 'sAMAccountName=test.user' \
                -d1
        ~~~

        * d1 argument is for debug mode

## Errors

### Errors if certificate hasn't been installed to ldap conf

* ERROR: TLS: peer cert untrusted or revoked (0x42)

    ~~~sh
    ldap_url_parse_ext(ldaps://ldap.example-domain.com)
    ldap_create
    ldap_url_parse_ext(ldaps://ldap.example-domain.com:636/??base)
    Enter LDAP Password:
    ldap_sasl_bind
    ldap_send_initial_request
    ldap_new_connection 1 1 0
    ldap_int_open_connection
    ldap_connect_to_host: TCP ldap.example-domain.com:636
    ldap_new_socket: 3
    ldap_prepare_socket: 3
    ldap_connect_to_host: Trying 12.34.56.78:636
    ldap_pvt_connect: fd: 3 tm: -1 async: 0
    attempting to connect:
    connect success
    TLS: peer cert untrusted or revoked (0x42)
    TLS: can't connect: (unknown error code).
    ldap_err2string
    ldap_sasl_bind(SIMPLE): Can't contact LDAP server (-1)
    ~~~

* ERROR: ldap_sasl_bind(SIMPLE): Can't contact LDAP server (-1)

    ~~~sh
    ldap_sasl_bind(SIMPLE): Can't contact LDAP server (-1)
    TLS: can't connect: error:14090086:SSL routines:ssl3_get_server_certificate:certificate verify failed (unable to get local issuer certificate).
    ~~~

* **Fix for both errors**

    ~~~sh
    # Download CA /usr/local/share/ca-certificates/root-ca-01.crt and add it into ldap.conf
    cp /etc/ldap/ldap.conf /etc/ldap/ldap.conf.orig
    echo "TLS_CACERT      /usr/local/share/ca-certificates/root-ca-01.crt" >> /etc/ldap/ldap.conf
    ~~~
