# Linux: How to create and inspect security certificates (SSL, HTTPS, etc...)

* Main source https://www.feistyduck.com/library/openssl-cookbook/online/ch-openssl.html#

## Vocabulary

* CSR = Certificate Signing Request
* CRT = Certificate
* CA = Certificate Authority
* Root CA = Root Certificate Authority, which is the master signing authority
* DN = Domain Name
* FQDN = Fully Qualified Domain Name. For example server with hostname "server01", FQDN could be server01.domain.com
* AIA = Authority Information Access
* OCSP = Online Certificate Status Protocol
* OID = Object Identifier
* CPS = Certificate Policy Statement
* CRL = Certificate Revocation List
* CDP = Certificate Distribution Point
* TLS = Transport Layer Security

#### QA about CRL, CDP, and OCSP
* ***Should we configure OCSP URL in Offline Root CA extension or not?***
  * Short answer: No need, Root CA's CRL size is not big, but admin overhead would be quite big.
  * https://social.technet.microsoft.com/Forums/ie/en-US/cf0ca8de-5c2f-4e88-9929-2601928dac5a/offline-root-ca-ocsp-url-configuration-under-extensio
* ***Correct CRL and OSCP URIs along certificate chain***
  * https://security.stackexchange.com/questions/229284/correct-crl-and-oscp-uris-along-certificate-chain
* ***How does an offline Root CA sign OCSP Response?***
  * https://security.stackexchange.com/questions/221274/how-does-an-offline-root-ca-sign-ocsp-response

#### Check which cipher suites are obsolete and do not use them
  * Table 1.5. Cipher keywords, reference Feisty Duck OpenSSL Cookbook, last update 1.11.2020
  * Check the tables in Feisty Duck OpenSSL CoocBook to see overview which keywords are insecure/obsolete.

Keyword | Meaning
-- | -- 
3DES | Cipher suites using triple DES. Obsolete and insecure.
AES | Cipher suites using AES.
AESGCM (v1.0.0+) | Cipher suites using AES GCM.
CAMELLIA | Cipher suites using Camellia. Obsolete.
DES | Cipher suites using single DES. Obsolete and insecure.
eNULL, NULL | Cipher suites that don’t use encryption. Insecure.
IDEA |Cipher suites using IDEA. Obsolete.
RC2 | Cipher suites using RC2. Obsolete and insecure.
RC4 | Cipher suites using RC4. Insecure.
SEED | Cipher suites using SEED. Obsolete.

#### To generate an RSA key, use the genrsa command:
  
    openssl genrsa -aes384 -out fd.key 2048

#### See structured output

    openssl rsa -text -in fd.key

#### Extract public part from the created key

   openssl rsa -in fd.key -pubout -out fd-public.key

#### Check that public key is public key. 
* The first line should be: -----BEGIN PUBLIC KEY-----

    cat fd-public.key

#### Creating a CSR (Certificate Signing Request)

    openssl req -new -key fd.key -out fd.csr

#### Creating a CSR (Certificate Signing Request) from existing certificate

    openssl x509 -x509toreq -in fd.crt -out fd.csr -signkey fd.key

#### Configuration file for CSR generation
~~~
[req]
prompt = no
distinguished_name = dn
req_extensions = ext
input_password = PASSPHRASE

[dn]
CN = www.feistyduck.com
emailAddress = webmaster@feistyduck.com
O = Feisty Duck Ltd
L = London
C = GB

[ext]
subjectAltName = DNS:www.feistyduck.com,DNS:feistyduck.com
~~~
* Create CSR easily with configuration file

    openssl req -new -config fd.cnf -key fd.key -out fd.csr

#### Signing your own certificate

    openssl x509 -req -days 365 -in fd.csr -signkey fd.key -out fd.crt
* Sign self-signed certificate without generating a CSR

      openssl req -new -x509 -days 365 -key fd.key -out fd.crt
* Sign without any questions by adding subject information with -subj switch

      openssl req -new -x509 -days 365 -key fd.key -out fd.crt \
        -subj "/C=GB/L=London/O=Feisty Duck Ltd/CN=www.feistyduck.com"
 
 
#### WARNING When a certificate contains alternative names, all common names are ignored. Newer certificates produced by CAs may not even include any common names. For that reason, include all desired hostnames on the alternative names list.
* Create text file fd.ext with content

      subjectAltName = DNS:*.feistyduck.com, DNS:feistyduck.com
* Issue certificate using x509
~~~
openssl x509 -req -days 365 \
-in fd.csr -signkey fd.key -out fd.crt \
-extfile fd.ext
~~~

#### Check the content of certificate "-noout" means that the encoded cert is not printed, making the print easier to read.

    openssl x509 -text -in fd.crt -noout

#### CRL Distribution Points, http is fine for distributing Certificate Revocation List (CRL) 
~~~
X509v3 CRL Distribution Points:
    Full Name:
      URI:http://crl.starfieldtech.com/sfs3-20.crl
~~~

## Creating a private certification authority


### Root CA configuration file
* Link to OpenSSL Cookbook templates https://github.com/ivanr/bulletproof-tls/tree/master/private-ca
* **root_ca.conf** file with comments https://github.com/iisti/it-admin-tricks/blob/master/security_certs/root_ca.conf
* One can test if the template and commented root ca are same with:
~~~
wget <template-root-ca>
wget <commented-root-ca>
# Remove comments
sed '^#/d' <commented-root-ca> > <uncommented-root-ca>
diff <template-root-ca> <uncommented-root-ca>
~~~

### Root CA Directory Structure

Directory | Meaning
-- | --
root-ca/ | Root directory
root-ca/certs/ | New certificates will be placed here as they are issued.
root-ca/db/ | Certificate database (index) and files that holds the next certificate and CRL serial numbers.
root-ca/private/ | Private key store, one for the CA and another for OCSP responder. No other user should have access to this.

~~~
mkdir root_ca
cd root_ca
mkdir certs db private
chmod 700 private
touch db/index
openssl rand -hex 16  > db/serial
echo 1001 > db/crlnumber
~~~

* **NOTE** initialize the certificate serial numbers with a random number generator, so the serial number will not conflict if multiple CA certificates are with same distinguished name. This way there will be no conflicts if mistakes are made and certificates need to be re-created.

### Root CA generation
* Download and edit the root-ca.conf
* Generate root CA CSR
~~~
openssl req -new \
    -config root-ca.conf \
    -out root-ca.csr \
    -keyout private/root-ca.key
~~~

* Sign the Root CA CSR to generate self-signed certificate. *-extensions* switch points to *ca_ext* section.
~~~
openssl ca -selfsign \
    -config root-ca.conf \
    -in root-ca.csr \
    -out root-ca.crt \
    -extensions ca_ext
~~~

### Structure of the database file
* db/index, one can do `cat index` and the output should be something like below (the header is not in the file).

Status flag | Expiration date | Revocation date | Serial number | File location | Distinguished Name
-- | -- | -- | -- | -- | --
1 | 2 | 3 | 4 | 5 | 6 
V | 240706115345Z | | 1001 | unknown | /C=GB/O=Example/CN=Root CA |

1. Status flag (V for valid, R for revoked, E for expired)
1. Expiration date (in YYMMDDHHMMSSZ format)
1. Revocation date or empty if not revoked
1. Serial number (hexadecimal)
1. File location or unknown if not known
1. Distinguished name

### Root CA operations
* Generate a CRL from root CA
~~~
openssl ca -gencrl \
    -config root-ca.conf \
    -out root-ca.crl
~~~

* Issue a CA certificate, use *-extensions* switch to create sub CA.
~~~
openssl ca \
    -config root-ca.conf \
    -in sub-ca.csr \
    -out sub-ca.crt \
    -extensions sub_ca_ext
~~~

* Revoke a certificate, use *-revoke* switch. Check serial number from database.
  * Reason can be defined with *-crl_reason* switch:
    * unspecified, keyCompromise, CACompromise, affiliationChanged, superseded, cessationOfOperation, certificateHold, and removeFromCRL.
    ~~~
    openssl ca \
        -config root-ca.conf \
        -revoke certs/2BC1A13CB63A0BF56DC730C3359843B3.pem \
        -crl_reason keyCompromise
    ~~~
  * Before revocation (the header is not in the **index** file).

Status flag | Expiration date | Revocation date | Serial number | File location | Distinguished Name
-- | -- | -- | -- | -- | --
V | 240706115345Z | | 2BC1A13CB63A0BF56DC730C3359843B3 | unknown | /C=FI/ST=Hame/O=IT/OU=IT/CN=server01.domain.com/emailAddress=mail@domain.com |

  * After revocation

Status flag | Expiration date | Revocation date | Serial number | File location | Distinguished Name
-- | -- | -- | -- | -- | --
V | 240706115345Z | 210120123202Z,keyCompromise | 2BC1A13CB63A0BF56DC730C3359843B3 | unknown | /C=GB/ST=London/O=IT/OU=IT/CN=server01.domain.com/emailAddress=mail@domain.com |

### Create a certificate for OCSP signing
* Create private key and CSR for the OCSP responder.

~~~
openssl req -new \
    -newkey rsa:2048 \
    -subj "/C=GB/O=Example/CN=OCSP Root Responder" \
    -keyout private/root-ocsp.key \
    -out root-ocsp.csr
~~~

* Issue OSCP certificate with root CA and use *-extensions* switch with *ocsp_ext*.
  * OCSP certificates can't be revoced, because they don't contain revocation information. That's why it's good to keep the life time short. Here 30 days was chosen. This means a new certificate is required to be generated every 30 days.
  ~~~
  openssl ca \
      -config root-ca.conf \
      -in root-ocsp.csr \
      -out root-ocsp.crt \
      -extensions ocsp_ext \
      -days 30
  ~~~

* One can test OCSP responder on the same server as root CA resides, but in production OCSP responder key and certificate should reside elsewhere.
  ~~~
  openssl ocsp \
      -port 9080 \
      -index db/index \
      -rsigner root-ocsp.crt \
      -rkey private/root-ocsp.key \
      -CA root-ca.crt \
      -text
  ~~~
  * Test the operation of the OCSP responder with command:
  ~~~
  openssl ocsp \
      -issuer root-ca.crt \
      -CAfile root-ca.crt \
      -cert root-ocsp.crt \
      -url http://127.0.0.1:9080
  ~~~
  * Response shloud be something like:
  ~~~
  Response verify OK
  root-ocsp.crt: good
          This Update: Jul  9 18:45:34 2014 GMT
  ~~~

### Creating a Subordinate CA

* What is change compared to root-ca.conf?
  * *ocsp* command doesn't understand virtual hosts <-- what does that mean?
* Note that Chrome will give an error if server certificate is valid longer than 1 year.
  * Source: https://stackoverflow.com/questions/64597721/neterr-cert-validity-too-long-the-server-certificate-has-a-validity-period-t
~~~
[default]
name                    = sub-ca
ocsp_url                = http://ocsp.$name.$domain_suffix:9081

[ca_dn]
commonName              = "Sub CA"

[ca_default]
copy_extensions         = copy
default_days            = 365
default_crl_days        = 30
~~~
  * From root_ca.conf ***ca_ext*** and ***sub_ca_ext*** sections are replaced with ***server_ext*** and ***client_ext***.
  * There's no ***name_constraints*** section in sub_ca.conf.

* Link to OpenSSL Cookbook templates https://github.com/ivanr/bulletproof-tls/tree/master/private-ca
* **sub-ca.conf** file with comments https://github.com/iisti/it-admin-tricks/blob/master/security_certs/sub_ca.conf
* The differences can be checked as in Root CA section previosly.

### Subordinate CA Directory Structure
* Create similar structure as Root CA, but name it differently, for example *sub-ca*.

### Subordinate CA generation
* *-config* switch pickus up the *sub-ca.conf* for creating a CSR
~~~
openssl req -new \
    -config sub-ca.conf \
    -out sub-ca.csr \
    -keyout private/sub-ca.key
~~~
* Issue the sub CA with root CA using *-extensions* switch pointing to *sub_ca_ext*
~~~
openssl ca \
    -config root-ca.conf \
    -in sub-ca.csr \
    -out sub-ca.crt \
    -extensions sub_ca_ext
~~~

### Subordinate CA operations
* Inspect the CSR before issuing a certificate. Escpecially if you got the CSR from 3rd pary.
  * Pay special attention to *basicConstraints* and *subjectAlternativeName* extensions.
* To create a server certificate from CSR specify *server_ext* with *-extensions* switch
~~~
openssl ca \
    -config sub-ca.conf \
    -in server.csr \
    -out server.crt \
    -extensions server_ext
~~~
* To create a client certificate from CSR specify *client_ext* with *-extensions* switch
~~~
openssl ca \
    -config sub-ca.conf \
    -in client.csr \
    -out client.crt \
    -extensions client_ext
~~~

### CRL and OCSP
* CRL and certificate revocation works the same way as with root CA.
* OCSP responder should use it's own certificate, which avoids keeping the subordinate CA on a public server.

### CRL and OCSP
* CRL and certificate revocation works the same way as with root CA.
* OCSP responder should use it's own certificate, which avoids keeping the subordinate CA on a public server.

# TLDR; Quick instructions
* Generating Root CA, Sub CA and other certs.

## Root CA
1. Variable for storing root CA name, so it's easier to create different names.
    ~~~
    rootca="root-ca-01"
    ~~~
1. Create directories and files for root CA
    ~~~
    mkdir "$rootca" && \
    cd "$rootca" && \
    mkdir certs db private && \
    chmod 700 private && \
    touch db/index && \
    openssl rand -hex 16  > db/serial && \
    echo 1001 > db/crlnumber
    ~~~
1. Download root-ca-template.conf
    * Note that if the GitHub repo is private, one needs to open the file as RAW in browser, so that token is created.
    ~~~    
    wget https://github.com/iisti/it_admin_tricks_private/blob/master/security/certificates/root-ca-template.conf -O root-ca-template.conf
    cp root-ca-template.conf "$rootca".conf
    ~~~
1. Edit the root ca configuration file
   * Edit these lines
       ~~~
       4 name                    = root-ca
       5 domain_suffix           = example.com
       ...
       12 [ca_dn]
       13 countryName             = "GB"
       14 organizationName        = "Example"
       15 commonName              = "Root CA"
       ~~~
   * ocsp_url for Root Ca is not really needed as CRL file should be small.
       ~~~ 
       #8 ocsp_url                = http://ocsp.$name.$domain_suffix:9080
       #88 OCSP;URI.0              = $ocsp_url
       ~~~
   * Nameconstraints section can be commented out as it's not supported by all platforms.
       ~~~
       #80 nameConstraints         = @name_constraints
       ~~~
3. Generate root CA CSR
    ~~~
    openssl req -new \
        -config "$rootca".conf \
        -out "$rootca".csr \
        -keyout private/"$rootca".key
    ~~~
1. Sign the Root CA CSR to generate self-signed certificate. ***-extensions*** switch points to ***ca_ext*** section.
    ~~~
    openssl ca -selfsign \
        -config "$rootca".conf \
        -in "$rootca".csr \
        -out "$rootca".crt \
        -extensions ca_ext
    ~~~

##### CRL Root CA
1. Generate a CRL from root CA
    ~~~
    openssl ca -gencrl \
        -config "$rootca".conf \
        -out "$rootca".crl
    ~~~

##### OCSP Root CA
* Skip this if you're not using OCSP for Root CA
1. Create OCSP CSR
    ~~~
    openssl req -new \
        -newkey rsa:2048 \
        -subj "/C=GB/O=Example/CN=OCSP Root Responder" \
        -keyout private/root-ocsp.key \
        -out root-ocsp.csr
    ~~~
1. Issue OCSP certificate
    ~~~
    openssl ca \
        -config "$rootca".conf \
        -in root-ocsp.csr \
        -out root-ocsp.crt \
        -extensions ocsp_ext \
        -days 30
    ~~~
1. Test OCSP locally with OpenSSL
   * Start OCSP responder
     ~~~
     openssl ocsp \
         -port 9080 \
         -index db/index \
         -rsigner root-ocsp.crt \
         -rkey private/root-ocsp.key \
         -CA "$rootca".crt \
         -text
     ~~~
    * Test OCSP responder
      ~~~
      openssl ocsp \
          -issuer "$rootca".crt \
          -CAfile "$rootca".crt \
          -cert root-ocsp.crt \
          -url http://127.0.0.1:9080
      ~~~
    * Response should be
      ~~~
      Response verify OK
      test-root-ocsp.crt: good
       This Update: Jan  5 17:13:26 2021 GMT
      ~~~

## Sub CA
1. Download sub-ca-template.conf.
   * Check the GitHub Raw URL 
   ~~~
   wget https://github.com/iisti/it_admin_tricks_private/blob/master/security/certificates/sub-ca-template.conf -O sub-ca-template.conf
   ~~~
1. Save sub-ca name into variable.
   ~~~
   subca="sub-ca-01"
   ~~~
1. Save the sub CA template with the new name.
   ~~~
   cp sub-ca-template.conf "$subca".conf
   ~~~
1. Edit sub CA conf
   * Change these lines
   ~~~
   4 name                    = sub-ca
   5 domain_suffix           = example.com
   
   12 [ca_dn]
   13 countryName             = "GB"
   14 organizationName        = "Example"
   15 commonName              = "Sub CA"
   ~~~
   * ocsp_url depending on certificate usage, CRL file can be small and OCSP can be skipped.
   ~~~ 
   #8 ocsp_url                = http://ocsp.$name.$domain_suffix:9080
   #84 OCSP;URI.0              = $ocsp_url
   ~~~
3. Create Sub CA CSR
   ~~~
   openssl req -new \
       -config "$subca".conf \
       -out "$subca".csr \
       -keyout private/"$subca".key
   ~~~
1. Issue a CA certificate, use -extensions switch to create sub CA.
    ~~~
    openssl ca \
        -config "$rootca".conf \
        -in "$subca".csr \
        -out "$subca".crt \
        -extensions sub_ca_ext
    ~~~
    
#### CRL for Sub CA
* Generate a CRL for Sub CA
    ~~~
    openssl ca -gencrl \
        -config "$subca".conf \
        -out "$subca".crl
    ~~~
    
#### How to sign CSRs with Sub CA
* Sign a server CSR
    ~~~
    openssl ca \
        -config "$subca".conf \
        -in server.csr \
        -out server.crt \
        -extensions server_ext
    ~~~
* Sign a client CSR
    ~~~
    openssl ca \
        -config "$subca".conf \
        -in client.csr \
        -out client.crt \
        -extensions client_ext
    ~~~

##### OCSP for Sub CA
* Depending on the purpose of the certs, OCSP can be over kill if there are like 10 servers communicating each other. So this might be okay to skip.
* Variable for easier file management
    ~~~
    subocsp="sub-ocsp-01"
    ~~~
* Create OCSP CSR
    ~~~
    openssl req -new \
        -newkey rsa:2048 \
        -subj "/C=AT/O=Example/CN=OCSP Sub Responder" \
        -keyout private/"$subocsp".key \
        -out "$subocsp".csr
    ~~~
* Issue OCSP certificate
    ~~~
    openssl ca \
        -config "$subca".conf \
        -in "$subocsp".csr \
        -out "$subocsp".crt \
        -extensions ocsp_ext \
        -days 30
    ~~~
###### Test Sub CA OCSP cert
* Start OCSP responder locally
    ~~~
    openssl ocsp \
        -port 9080 \
        -index db/index \
        -rsigner "$subocsp".crt \
        -rkey private/"$subocsp".key \
        -CA "$subca".crt \
        -text
    ~~~
* Create certificate chain file
    ~~~
    cat "$subocsp".crt "$sub-ca".crt root-ca.crt > "$subocsp"-chain.crt
    ~~~
* Test the cert against local OCSP responder
    ~~~
    openssl ocsp \
        -issuer "$subca".crt \
        -CAfile "$subocsp"-chain.crt \
        -cert "$subocsp".crt \
        -url http://127.0.0.1:9080
    ~~~
    * Response should be something like
        ~~~
        Response verify OK
        sub-ocsp-01.crt: good
            This Update: Jun  1 08:35:34 2021 GMT
        ~~~

## Server certificate
* Download **server-cert-template.conf** and modify it to your purposes.
    ~~~
    wget https://github.com/iisti/it_admin_tricks_private/blob/master/security/certificates/server-cert-template.conf -O server-cert-template.conf
    ~~~
* Save the configuration with name **server-01_openssl.conf** or something similar.
    ~~~
    server="server-01"
    cp server-cert-template.conf "$server"_openssl.conf
    ~~~
* Edit the "$server"\_openssl.conf file to fit the server needs.
  * Make sure that alternative DNS names section *alt_names* has every DNS/hostname that are intended to be used. Also Windows requires that the exact hostname of the machine is in there, so that Windows will accept it for LDAPS server certificate.
* Generate server CSR
    ~~~
    openssl req \
        -out $server.csr \
        -newkey rsa:2048 \
        -nodes \
        -keyout private/$server.key \
        -config "$server"_openssl.conf
    ~~~
* Sign server CSR with Sub CA
  * Notice to set the ***-days*** to desired value. Browsers will show warning/error pages if certificate is valid for over 1 year. For internal server <-> server communication, one can probably create certificates with longer validity periods. 
    ~~~
    subcaconf="$subca".conf
    openssl ca \
        -config $subcaconf \
        -in $server.csr \
        -out $server.crt \
        -days 365 \
        -extensions server_ext
    ~~~
* Create chain file
    ~~~
    cat "$server".crt "$subca".crt "$rootca".crt > "$server"-chain.crt
    ~~~ 

#### Create PFX file formatted certificate for Windows
* .pfx file includes both private key and certificates in same file.
    ~~~
    openssl pkcs12 -export -out "$server".pfx \
      -inkey private/"$server".key \
      -in "$server"-chain.crt 
    ~~~
* Check [ldaps_ms.md](/ms_admin/ldaps_ms.md) for more information about LDAPS with Microsfot server.

## Verify the certificates with OpenSSL
* Verify Sub CA certificate
    ~~~
    openssl verify -verbose -x509_strict -CAfile "$rootca".crt -CApath ./ "$subca".crt
    ~~~
    * Should return:
        ~~~
        test-server.crt: OK
        ~~~
* Verify server certificate
    ~~~
    openssl verify -verbose -x509_strict -CAfile "$rootca".crt -CApath ./ -untrusted "$subca".crt "$server".crt
    ~~~
    * Should return:
        ~~~
        test-server.crt: OK
        ~~~
* Verifying running server
    ~~~
    openssl s_client -CAfile "$server"-chain.crt -servername server01.domain.com -connect server01.domain.com:443
    ~~~
    * Should return:
        ~~~
        Verify return code: 0 (ok)
        ~~~
* By default CRL is not checked and revoked certificate will return **0 (ok)** which is odd. The command below will check the CRL with local CRL file.
  * Notice that ***-crl_check*** does not download any CRL files and seems that ***-crl_download*** did not work correctly either.
    * Tested with version ***OpenSSL 1.1.1i  8 Dec 2020***
    * Source: https://superuser.com/a/742289/532911
    * Source2: https://github.com/openssl/openssl/issues/8581
  ~~~
  openssl s_client -CAfile "$server"-chain.crt -servername server01.domain.com -connect server01.domain.com:443 -crl_check -CRL "$subca".crl
  ~~~
    * Should return:
      ~~~
      Verify return code: 23 (certificate revoked)
      ~~~
  * One could add the CRL file also to the chain for testing purposes.
      ~~~
      cat "$server"-chain.crt "$subca".crl > "$server"-chain02.crt
      ~~~
      * Test
      ~~~
      openssl s_client -CAfile "$server"-chain02.crt -servername server01.domain.com -connect server01.domain.com:443 -crl_check
      ~~~ 
      * Should return:
          ~~~
          Verify return code: 23 (certificate revoked)
          ~~~
