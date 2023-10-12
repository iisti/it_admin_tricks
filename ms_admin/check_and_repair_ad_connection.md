# Testing Windows machine connection to Active Directory

## Insturctions for resetting machine password
* Fix Trust relationship Failed Issue Without Domain Rejoining
  * https://theitbros.com/fix-trust-relationship-failed-without-domain-rejoining/

## Check current Domain Controller
~~~
PS C:\Windows\System32> nltest /dsgetdc:sub.domain.com
           DC: \\dc-smb-01.sub.domain.com
      Address: \\192.168.71.10
     Dom Guid: e6728e84-d473-4d0b-ab4e-17554a33ffb4
     Dom Name: sub.domain.com
  Forest Name: sub.domain.com
 Dc Site Name: Default-First-Site-Name
Our Site Name: Default-First-Site-Name
        Flags: GC DS LDAP KDC TIMESERV GTIMESERV WRITABLE DNS_DC DNS_DOMAIN DNS_FOREST CLOSE_SITE FULL_SECRET
The command completed successfully
~~~

## Check if domain is reachable
~~~
PS C:\Windows\System32> netdom verify computer01 /Domain:sub.domain.com
The secure channel from computer01 to sub.domain.com is invalid.

We can't sign you in with this credential because your domain isn't available. Make sure your device is connected to your organization's network and try again. If you previously signed in on this device with another credential, you can sign in with that credential.

We can't sign you in with this credential because your domain isn't available. Make sure your device is connected to your organization's network and try again. If you previously signed in on this device with another credential, you can sign in with that credential.

The command failed to complete successfully.
~~~

## Change the Domain Controller where the machine is trying to connect
* Source https://www.technipages.com/windows-how-to-switch-domain-controller
* The DC might change on next reboot.
~~~
PS C:\Windows\System32> nltest /server:computer01 /sc_reset:sub.domain.com\dc-smb-03.sub.domain.com
Flags: 30 HAS_IP  HAS_TIMESERV
Trusted DC Name \\dc-smb-03.sub.domain.com
Trusted DC Connection Status Status = 0 0x0 NERR_Success
The command completed successfully
~~~

* /SERVER: is the name of the machine you want to force a connection **from**. e.g client1
* /SC_RESET is where you want to force the connection to which is the domain and domain controller in netbios format. e.g. DOMAIN\DC1
* This is using the **NetBIOS** names as opposed to DNS FQDN.

## Check now connection to the domain
~~~
PS C:\Windows\System32> netdom verify computer01 /Domain:sub.domain.com
The secure channel from computer01 to the domain sub.domain.com has been verified.  The connection
is with the machine \\dc-smb-03.sub.domain.com.

The command completed successfully.
~~~

## More tests when connected via VPN
~~~
PS C:\Windows\System32> nslookup sub.domain.com
Server:  UnKnown
Address:  10.167.14.20

Name:    sub.domain.com
Addresses:  10.167.14.6
          192.168.71.10
          192.168.20.105

PS C:\Windows\System32> ping sub.domain.com

Pinging sub.domain.com [10.167.14.6] with 32 bytes of data:
Reply from 10.167.14.6: bytes=32 time=46ms TTL=63
~~~

## Monitoring ping
* Source https://superuser.com/questions/348327/linux-how-to-monitor-incoming-pings
~~~
tcpdump ip proto \\icmp
~~~


## Test-ComputerSecureChannel
* Testing connection between Windows 10 laptop and Active Directory with Test-ComputerSecureChannel
* **Use PowerShell 7.1 or newer!** It can be installed via Microsoft Store for free.
* Source for installation https://github.com/PowerShell/PowerShell/issues/14123

~~~
PS C:\Windows\System32> gmo

ModuleType Version    PreRelease Name                                ExportedCommands
---------- -------    ---------- ----                                ----------------
Manifest   3.1.0.0               Microsoft.PowerShell.Management     {Add-Content, Clear-Content, Clear-Item, Clear-ItemProperty…}
Manifest   7.0.0.0               Microsoft.PowerShell.Utility        {Add-Member, Add-Type, Clear-Variable, Compare-Object…}
Script     1.4.7                 PackageManagement                   {Find-Package, Find-PackageProvider, Get-Package, Get-PackageProvider…}
Script     2.2.5                 PowerShellGet                       {Find-Command, Find-DscResource, Find-Module, Find-RoleCapability…}
Script     2.1.0                 PSReadLine                          {Get-PSReadLineKeyHandler, Get-PSReadLineOption, Remove-PSReadLineKeyHandler, Set-PSReadLineKeyHandler…}

# No Test-ComputerSecureChannel module found
PS C:\Windows\System32> gcm -mod Microsoft.PowerShell.Management | where name -match secure
~~~

* There's an old version of Microsoft.PowerShell.Management and Test-ComputerSecureChannel is not found. Let's install it.
* **Use PowerShell 7.1**
~~~
PS C:\Windows\System32> import-module Microsoft.PowerShell.Management -UseWindowsPowerShell

WARNING: Proxy creation has been skipped for the following command: 'gcb, gin, gtz, scb, stz, Add-Content, Clear-Content, Clear-Item, Clear-ItemProperty, Clear-RecycleBin, Convert-Path, Copy-Item, Copy-ItemProperty, Debug-Process, Get-ChildItem, Get-Clipboard, Get-ComputerInfo, Get-Content, Get-HotFix, Get-Item, Get-ItemProperty, Get-ItemPropertyValue, Get-Location, Get-Process, Get-PSDrive, Get-PSProvider, Get-Service, Get-TimeZone, Invoke-Item, Join-Path, Move-Item, Move-ItemProperty, New-Item, New-ItemProperty, New-PSDrive, New-Service, Pop-Location, Push-Location, Remove-Item, Remove-ItemProperty, Remove-PSDrive, Rename-Computer, Rename-Item, Rename-ItemProperty, Resolve-Path, Restart-Computer, Restart-Service, Resume-Service, Set-Clipboard, Set-Content, Set-Item, Set-ItemProperty, Set-Location, Set-Service, Set-TimeZone, Split-Path, Start-Process, Start-Service, Stop-Computer, Stop-Process, Stop-Service, Suspend-Service, Test-Connection, Test-Path, Wait-Process', because it would shadow an existing local command.  Use the AllowClobber parameter if you want to shadow existing local commands.
WARNING: Module Microsoft.PowerShell.Management is loaded in Windows PowerShell using WinPSCompatSession remoting session; please note that all input and output of commands from this module will be deserialized objects. If you want to load this module into PowerShell please use 'Import-Module -SkipEditionCheck' syntax.

PS C:\Windows\System32> gmo

ModuleType Version    PreRelease Name                                ExportedCommands
---------- -------    ---------- ----                                ----------------
Manifest   3.1.0.0               Microsoft.PowerShell.Management     {Add-Content, Clear-Content, Clear-Item, Clear…
Manifest   7.0.0.0               Microsoft.PowerShell.Management     {Add-Content, Clear-Content, Clear-Item, Clear…
Script     1.0                   Microsoft.PowerShell.Management     {Add-Computer, Checkpoint-Computer, Clear-Even…
Manifest   7.0.0.0               Microsoft.PowerShell.Utility        {Add-Member, Add-Type, Clear-Variable, Compare…
Script     1.4.7                 PackageManagement                   {Find-Package, Find-PackageProvider, Get-Packa…
Script     2.2.5                 PowerShellGet                       {Find-Command, Find-DscResource, Find-Module, …
Script     2.1.0                 PSReadLine                          {Get-PSReadLineKeyHandler, Get-PSReadLineOptio…

PS C:\Windows\System32> gcm -mod Microsoft.PowerShell.Management | where name -match secure

CommandType     Name                                               Version    Source
-----------     ----                                               -------    ------
Function        Test-ComputerSecureChannel                         1.0        Microsoft.PowerShell.Management
~~~

* Parameter **-Repair** breaks connection when connected via VPN (with current configuration)
~~~
PS C:\Windows\System32> Test-ComputerSecureChannel -Repair
False
# Disconnected from VPN
PS C:\Windows\System32> Test-ComputerSecureChannel -Repair
True
~~~

* When connected to GCP VPN, testing with Samba AD joined laptop.
* More commands: https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.management/test-computersecurechannel?view=powershell-5.1
~~~
PS C:\Windows\System32> Test-ComputerSecureChannel -Server "dc-smb-01.sub.domain.com"
True
PS C:\Windows\System32> Test-ComputerSecureChannel -Server "dc-smb-02.sub.domain.com"
True
PS C:\Windows\System32> Test-ComputerSecureChannel -Server "dc-smb-03.sub.domain.com"
True
~~~
