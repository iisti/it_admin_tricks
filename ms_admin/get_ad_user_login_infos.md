## Enable Lock/Unlock Event Logging
* Local Security Policy -> Advanced Audit Policy Configuration -> Logon/Logoff -> Audit Other Logon/Logoff Events
  * Description of **Audit Other Logon/Logoff Events**
      ~~~
      Other Logon/Logoff Events

      This policy setting allows you to audit other logon/logoff-related events that are not covered in the “Logon/Logoff” policy setting such as the following:
            Terminal Services session disconnections.
            New Terminal Services sessions.
            Locking and unlocking a workstation.
            Invoking a screen saver.
            Dismissal of a screen saver.
            Detection of a Kerberos replay attack, in which a Kerberos request was received twice with identical information. This condition could be caused by network misconfiguration.
            Access to a wireless network granted to a user or computer account.
            Access to a wired 802.1x network granted to a user or computer account.

      Volume: Low.

      Default: No Auditing.
      ~~~

## Filter one username from Event viewer
* Use XML filter. You can check the syntax from one of the results -> Details -> XML view.

      # This one works with AD user and local user
      <QueryList>
        <Query Id="0" Path="Security">
          <Select Path="Security">
            *[EventData[Data[@Name='TargetUserName']='user.name']]
          </Select>
        </Query>
      </QueryList>
      
      
      # For auditing Logons from domain. Checks EventID 4624, Domain and LogonType 10=RDP
      # More of LogonTypes https://www.ultimatewindowssecurity.com/securitylog/encyclopedia/event.aspx?eventID=4624
      <QueryList>
        <Query Id="0" Path="Security">
          <Select Path="Security">
            *[
            System[(EventID='4624')]
            and
            EventData[Data[@Name='TargetDomainName']='DOMAIN']
            and
            EventData[Data[@Name='LogonType']='10']
            ]
          </Select>
        </Query>
      </QueryList>

## PowerShell: local or AD user login information
* Source: https://mikefrobbins.com/2015/10/01/powershell-filter-by-user-when-querying-the-security-event-log-with-get-winevent-and-the-filterhashtable-parameter/
* Event IDs
  * 4624 = logged on
  * 4800 = locked
  * 4801 = unlocked 
* This one-liner will retrieve logins from current day.
    ~~~
    $username="iisti"; $yesterday=(Get-Date) - (New-TimeSpan -Day 1); Get-WinEvent -FilterHashtable @{logname='security';id=4624,4800,4801;data=$username} | Where-Object { $_.TimeCreated -ge $yesterday }
    ~~~
* For retriving current user's information one can user  `$username=(whoami).split('\')[1];`, split is required so that the domain part is left out.
    ~~~
    $username=(whoami).split('\')[1]; $yesterday=(Get-Date) - (New-TimeSpan -Day 1); Get-WinEvent -FilterHashtable @{logname='security';id=4624,4800,4801;data=$username} | Where-Object { $_.TimeCreated -ge $yesterday }
    ~~~
* One can add parameter `select -ExpandProperty message` if the message needs to be read
    ~~~
    $username="iisti"; $yesterday=(Get-Date) - (New-TimeSpan -Day 1); Get-WinEvent -FilterHashtable @{logname='security';id=4624,4800,4801;data=$username} | Where-Object { $_.TimeCreated -ge $yesterday } | select -ExpandProperty message
    ~~~

## PowerShell: Get all account informations from AD
* How to get all accounts in AD via PowerShell
  * https://www.deliveron.com/blog/query-user-accounts-active-directory-powershell/
* How to get AD user login history via PowerShell
  * https://social.technet.microsoft.com/wiki/contents/articles/51413.active-directory-how-to-get-user-login-history-using-powershell.aspx

* On AD VM **open Powershell as Administrator**:

      Import-module ActiveDirectory
      PS C:\Users\sysop> Get-ADUser -Filter {Surname -eq "Somelastname"} -SearchBase "OU=myorg,DC=mydomain,DC=com" -Properties mail,Name,ObjectClass,Enabled |
        Select mail,Name,ObjectClass,Enabled

      mail                                      Name                        ObjectClass Enabled
      ----                                      ----                        ----------- -------
      somefirstname.somelastname@mydomain.com Somefirstname Somelastname  user           True


* Get more information with a script
  * Open Windows PowerShell ISE as an administrator

        PS C:\Windows\system32> Import-module ActiveDirectory


        #### Script for checking info of 1 user ####
        # Edit the user base
        $search_base = "OU=myorg,DC=mydomain,DC=com"
        
        $date = Get-Date -Format "dd.MM.yyyy"
        $user = Read-Host -Prompt 'Input sAMAccountName'

        # Print the user. properties variable is used, so that the command doesn't grow long.
        $properties = 'mail,Name,sAMAccountName,ObjectClass,Enabled,LastLogonTimestamp,LastLogonDate,description' -split ','
        Get-ADUser -Filter {sAMAccountName -eq $user} -SearchBase $search_base -Properties $properties |
          Select $properties

  * Script output
   
        Input sAMAccountName: somefirstname.somelastname


        mail               : somefirstname.somelastname@mydomain.com
        Name               : Somefirstname Somelastname
        sAMAccountName     : somefirstname.somelastname
        ObjectClass        : user
        Enabled            : True
        LastLogonTimestamp : 132433328056832574
        LastLogonDate      : 31.08.2020 09:33:25
        description        :  

  * Comparing LastLogonTimestamp to LastLogonDate
  
        PS C:\Windows\system32> w32tm /ntte 132433328056832574
        153279 07:33:25.6832574 - 31.08.2020 09:33:25 

### Export all users:

    # User base
    $search_base = "OU=myorg,DC=mydomain,DC=com"
    
    $date = Get-Date -Format "yyyy-MM-dd"

    # Properties variable is used, so that the command doesn't grow long.
    # LastLogonTimestamp is good to have for easy sorting in Office sheet program.
    $properties = 'mail,Name,sAMAccountName,ObjectClass,Enabled,LastLogonTimestamp,LastLogonDate,description' -split ','
    
    Get-ADUser -Filter * -SearchBase $search_base -Properties $properties |
      Select $properties |
      Export-CSV "$PSScriptRoot\ad-accounts-$date.csv"
