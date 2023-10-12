# Instructions for Windows servers

## Enable Single label domains
* It's bad practice to use single label domains, e.g. *computer-name.company-domain* in that *company-domain* is single label 
  * One should always use domain like *company-domain.com*. There can be all kind of DNS issues if single label domains are used.
* Error when trying to join Win 2012 R2 server into single label domain.
    ~~~
    Note: This information is intended for a network administrator.  If you are not your network's administrator, notify the administrator that you received this information, which has been recorded in the file C:\Windows\debug\dcdiag.txt.

    The domain name "mydomain" might be a NetBIOS domain name.  If this is the case, verify that the domain name is properly registered with WINS.

    If you are certain that the name is not a NetBIOS domain name, then the following information can help you troubleshoot your DNS configuration.

    DNS was successfully queried for the service location (SRV) resource record used to locate a domain controller for domain "mydomain":

    The query was for the SRV record for _ldap._tcp.dc._msdcs.mydomain

    The following domain controllers were identified by the query:
    dc1.mydomain
    dc2.mydomain
    .
    .
    .


    However no domain controllers could be contacted.

    Common causes of this error include:

    - Host (A) or (AAAA) records that map the names of the domain controllers to their IP addresses are missing or contain incorrect addresses.

    - Domain controllers registered in DNS are not connected to the network or are not running.
    ~~~
    * Fix by adding a registry key. Run in PowerShell/CMD
      ~~~
      REG ADD HKLM\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters /v AllowSingleLabelDnsDomain /t REG_DWORD /d 1
      ~~~

## Check Windows server settings via PowerShell
* Run `sconfig` in Administrator PowerShell

## Change password in AWS via Session Manager
* A newly created Windows 2016 server was giving error below when trying to retrieve password.
    ~~~
    Password is not available.
    The instance was launched from a custom AMI, or the default password has changed. A
    password cannot be retrieved for this instance. If you have forgotten your password, you can
    reset it using the Amazon EC2 configuration service. For more information, see Passwords for a
    Windows Server instance.
    ~~~
    * Password was changed via AWS Session Manager. With Session Manager one can connect into PowerShell session and run commands below.
        ~~~
        # Connect through Session Manager
        $Password = Read-Host -AsSecureString
        $UserAccount = Get-LocalUser -Name "administrator"
        $UserAccount | Set-LocalUser -Password $Password
        ~~~
