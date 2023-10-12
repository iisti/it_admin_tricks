# How to enable LDAPS connection into Windows server

## Testing LDAPS with ldp.exe
* Open Windows search and search for ldp.exe
    * Connect
      * Server: ldaps04.mydomain.com
      * Port: 636
      * SSL: Checked
      * Successful connection:
      ~~~
      ld = ldap_sslinit("ldaps04.mydomain.com", 636, 1);
      Error 0 = ldap_set_option(hLdap, LDAP_OPT_PROTOCOL_VERSION, 3);
      Error 0 = ldap_connect(hLdap, NULL);
      Error 0 = ldap_get_option(hLdap,LDAP_OPT_SSL,(void*)&lv);
      Host supports SSL, SSL cipher strength = 256 bits
      Established connection to ldaps04.mydomain.com.
      Retrieving base DSA information...
      Getting 1 entries:
      Dn: (RootDSE)
      configurationNamingContext: CN=Configuration,DC=Mydomain,DC=Com; 
      currentTime: 07.03.2022 14:29:42 W. Europe Standard Time; 
      defaultNamingContext: DC=Mydomain,DC=Com; 
      dnsHostName: ldaps04.mydomain.com; 
      domainControllerFunctionality: 6 = ( WIN2012R2 ); 
      domainFunctionality: 4 = ( WIN2008R2 ); 
      dsServiceName: CN=NTDS Settings,CN=ldaps04,CN=Servers,CN=Default-First-Site-Name,CN=Sites,CN=Configuration,DC=Mydomain,DC=Com; 
      forestFunctionality: 4 = ( WIN2008R2 ); 
      highestCommittedUSN: 950693; 
      isGlobalCatalogReady: TRUE; 
      isSynchronized: TRUE; 
      ldapServiceName: Mydomain.com:ldaps04$@MYDOMAIN.COM; 
      namingContexts (5): DC=Mydomain,DC=Com; CN=Configuration,DC=Mydomain,DC=Com; CN=Schema,CN=Configuration,DC=Mydomain,DC=Com; DC=DomainDnsZones,DC=Mydomain,DC=Com; DC=ForestDnsZones,DC=Mydomain,DC=Com; 
      rootDomainNamingContext: DC=Mydomain,DC=Com; 
      schemaNamingContext: CN=Schema,CN=Configuration,DC=Mydomain,DC=Com; 
      serverName: CN=ldaps04.mydomain.com,CN=Servers,CN=Default-First-Site-Name,CN=Sites,CN=Configuration,DC=Mydomain,DC=Com; 
      subschemaSubentry: CN=Aggregate,CN=Schema,CN=Configuration,DC=Mydomain,DC=Com; 
      supportedCapabilities (6): 1.2.840.113556.1.4.800 = ( ACTIVE_DIRECTORY ); 1.2.840.113556.1.4.1670 = ( ACTIVE_DIRECTORY_V51 ); 1.2.840.113556.1.4.1791 = ( ACTIVE_DIRECTORY_LDAP_INTEG ); 1.2.840.113556.1.4.1935 = ( ACTIVE_DIRECTORY_V61 ); 1.2.840.113556.1.4.2080 = ( ACTIVE_DIRECTORY_V61_R2 ); 1.2.840.113556.1.4.2237 = ( ACTIVE_DIRECTORY_W8 ); 
      supportedControl (37): 1.2.840.113556.1.4.319 = ( PAGED_RESULT ); 1.2.840.113556.1.4.801 = ( SD_FLAGS ); 1.2.840.113556.1.4.473 = ( SORT ); 1.2.840.113556.1.4.528 = ( NOTIFICATION ); 1.2.840.113556.1.4.417 = ( SHOW_DELETED ); 1.2.840.113556.1.4.619 = ( LAZY_COMMIT ); 1.2.840.113556.1.4.841 = ( DIRSYNC ); 1.2.840.113556.1.4.529 = ( EXTENDED_DN ); 1.2.840.113556.1.4.805 = ( TREE_DELETE ); 1.2.840.113556.1.4.521 = ( CROSSDOM_MOVE_TARGET ); 1.2.840.113556.1.4.970 = ( GET_STATS ); 1.2.840.113556.1.4.1338 = ( VERIFY_NAME ); 1.2.840.113556.1.4.474 = ( RESP_SORT ); 1.2.840.113556.1.4.1339 = ( DOMAIN_SCOPE ); 1.2.840.113556.1.4.1340 = ( SEARCH_OPTIONS ); 1.2.840.113556.1.4.1413 = ( PERMISSIVE_MODIFY ); 2.16.840.1.113730.3.4.9 = ( VLVREQUEST ); 2.16.840.1.113730.3.4.10 = ( VLVRESPONSE ); 1.2.840.113556.1.4.1504 = ( ASQ ); 1.2.840.113556.1.4.1852 = ( QUOTA_CONTROL ); 1.2.840.113556.1.4.802 = ( RANGE_OPTION ); 1.2.840.113556.1.4.1907 = ( SHUTDOWN_NOTIFY ); 1.2.840.113556.1.4.1948 = ( RANGE_RETRIEVAL_NOERR ); 1.2.840.113556.1.4.1974 = ( FORCE_UPDATE ); 1.2.840.113556.1.4.1341 = ( RODC_DCPROMO ); 1.2.840.113556.1.4.2026 = ( DN_INPUT ); 1.2.840.113556.1.4.2064 = ( SHOW_RECYCLED ); 1.2.840.113556.1.4.2065 = ( SHOW_DEACTIVATED_LINK ); 1.2.840.113556.1.4.2066 = ( POLICY_HINTS_DEPRECATED ); 1.2.840.113556.1.4.2090 = ( DIRSYNC_EX ); 1.2.840.113556.1.4.2205 = ( UPDATE_STATS ); 1.2.840.113556.1.4.2204 = ( TREE_DELETE_EX ); 1.2.840.113556.1.4.2206 = ( SEARCH_HINTS ); 1.2.840.113556.1.4.2211 = ( EXPECTED_ENTRY_COUNT ); 1.2.840.113556.1.4.2239 = ( POLICY_HINTS ); 1.2.840.113556.1.4.2255; 1.2.840.113556.1.4.2256; 
      supportedLDAPPolicies (19): MaxPoolThreads; MaxPercentDirSyncRequests; MaxDatagramRecv; MaxReceiveBuffer; InitRecvTimeout; MaxConnections; MaxConnIdleTime; MaxPageSize; MaxBatchReturnMessages; MaxQueryDuration; MaxTempTableSize; MaxResultSetSize; MinResultSets; MaxResultSetsPerConn; MaxNotificationPerConn; MaxValRange; MaxValRangeTransitive; ThreadMemoryLimit; SystemMemoryLimitPercent; 
      supportedLDAPVersion (2): 3; 2; 
      supportedSASLMechanisms (4): GSSAPI; GSS-SPNEGO; EXTERNAL; DIGEST-MD5;
      ~~~
      * Failed test with a machine that doesn't have the necessary Root CA installed.
         * This error can also pop up if the server name is not configured correctly in alternative DNS names.
      ~~~
      ld = ldap_sslinit("ldaps04.mydomain.com", 636, 1);
      Error 0 = ldap_set_option(hLdap, LDAP_OPT_PROTOCOL_VERSION, 3);
      Error 81 = ldap_connect(hLdap, NULL);
      Server error: <empty>
      Error <0x51>: Fail to connect to ldaps04.mydomain.com.
      ~~~

## Checking the LDAPS certificate in use
* RDP into the LDAPS server
* certmgr -> Personal -> Certificates
    * ldaps04.mydomain.com
    * Check also alternative DNS names if they are being used.

## Import a pfx file
* One can be import a .pfx file by copying into Windows machine and double clicking.
  * Which certs exists can be checked before hand and see if the new certs/private key appear into registry
    * Regedit.exe
      * HKLM\SOFTWARE\Microsoft\Cryptography\Services\NTDS\SystemCertificates\My\Certificates\
  * If you're creating an LDAPS server, just import the files into Personal directory in the Certificate Manager.
  * Notice that there's no need to install role Active Directory Lightweight Directory Services, so that LDAPS works.
* Check [linux_certs.md](/security/certificates/linux_certs.md) for information how to create a .pfx cert in Linux.

## Installing the LDAPS root CA into Debian
* Notice that the certificate file name needs to end with .crt
~~~
sudo cp root-ca.pem /usr/local/share/ca-certificates/ldaps-root-ca.crt
sudo update-ca-certificates
        Updating certificates in /etc/ssl/certs...
        1 added, 0 removed; done.
        Running hooks in /etc/ca-certificates/update.d...
        done.
~~~

## Testing with Linux
* Linux requires tools
~~~
# Debian
sudo apt install ldap-utils

# CentOS
sudo yum install openldap-clients
~~~
* Output when Debian doesn't have the LDAPS Root CA installed.
   ~~~
    ldapsearch -x -D "CN=User Name,OU=Users,DC=Mydomain,DC=Com" \
        -W -H ldaps://ldaps04.mydomain.com \
        -b 'OU=Users,DC=Mydomain,DC=Com' \
        -s sub 'sAMAccountName=user.name'

    Enter LDAP Password:
    ldap_sasl_bind(SIMPLE): Can't contact LDAP server (-1)
   ~~~
* Output when the connection works
   ~~~
   ldapsearch -x -D "CN=User Name,OU=Users,DC=Mydomain,DC=Com" \
      -W -H ldaps://ldaps04.mydomain.com \
      -b 'OU=Users,DC=Mydomain,DC=Com' \
      -s sub 'sAMAccountName=user.name'

   Enter LDAP Password:
   # extended LDIF
   #
   # LDAPv3
   # base <OU=Users,DC=Mydomain,DC=Com> with scope subtree
   # filter: sAMAccountName=user.name
   # requesting: ALL
   #
   ~~~
