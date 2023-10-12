# Installing SharePoint 2013 Foundation SP1 on Windows 2012 R2

1. Disable IE Enhanced Security Configuration for administrators from Server Manager
1. Extract sharepoint_2013_foundation_sp1.7z
    * The packet was created with these instructions
    * https://docs.microsoft.com/en-us/sharepoint/troubleshoot/installation-and-setup/setup-error-if-.net-framework-4.6-is-installed
    
    ~~~
    # Download SharePoint 2013 Foundation SP1 installer
    # Extract the installer via CMD. At least 7zip failed to extract the installer correctly.
    sharepoint.exe /extract:C:\SharePointInstaller
    # Download wsssetup_15-0-4709-1000_x64.zip and copy wsssetup.dll to the SharePointInstaller folder
    ~~~

1. Run prerequisiteinstaller.exe
    * Output of the installer:
    
    ~~~
    • Microsoft .NET Framework 4.5: equivalent products already installed (no action taken)
    • Windows Management Framework 3.0: equivalent products already installed (no action taken)
    • Application Server Role, Web Server (IIS) Role: requires restart of the computer to complete installing
    • Microsoft SQL Server 2008 R2 SP1 Native Client: requires restart of the computer to complete installing
    • Windows Identity Foundation (KB974405): requires restart of the computer to complete installing
    • Microsoft Sync Framework Runtime v1.0 SP1 (x64): installed successfully
    • Windows Server AppFabric: installation error
    • Microsoft Identity Extensions: Installation skipped
    • Microsoft Information Protection and Control Client: Installation skipped
    • Microsoft WCF Data Services 5.0: Installation skipped
    • Microsoft WCF Data Services 5.6: Installation skipped
    • Cumulative Update Package 1 for Microsoft AppFabric 1.1 for Windows Server (KB2671763): Installation skipped
    ~~~

1. Click Finish and machine reboots automatically.
1. Microsoft SharePoint 2013 Products Preparation Tool continues installaiton process after reboot.
    * Output of the installer this time:
    
    ~~~
    • Microsoft .NET Framework 4.5: equivalent products already installed (no action taken)
    • Windows Management Framework 3.0: equivalent products already installed (no action taken)
    • Application Server Role, Web Server (IIS) Role: configured successfully
    • Microsoft SQL Server 2008 R2 SP1 Native Client: equivalent products already installed (no action taken)
    • Windows Identity Foundation (KB974405): was already installed (no action taken)
    • Microsoft Sync Framework Runtime v1.0 SP1 (x64): was already installed (no action taken)
    • Windows Server AppFabric: installed successfully
    • Microsoft Identity Extensions: installed successfully
    • Microsoft Information Protection and Control Client: installed successfully
    • Microsoft WCF Data Services 5.0: installed successfully
    • Microsoft WCF Data Services 5.6: installed successfully
    • Cumulative Update Package 1 for Microsoft AppFabric 1.1 for Windows Server (KB2671763): installed successfully
    ~~~

1. Click Finish and machine reboots automatically.
1. Microsoft SharePoint 2013 Products Preparation Tool continues installaiton process after reboot.
1. Click Finish, this time machine doesn't reboot anymore.
1. Run C:\01-install\sharepoint_2013_foundation\sharepoint_2013_foundation_sp1\setup.exe

    ~~~
    Server Type
    Stand-alone - Use for trial or development environments
    -Installs all components on a single server.
    -This installation cannot add servers to create a SharePoint farm.
    -Includes SQL Server 2008 R2 Express Edition with SP1 in English.
    ~~~

1. Run the Sharepoint Products Configuration Wizard now.
    * The errors which pop-up can't be fixed before hand as some direcotries don't exist before running the wizard.

    ~~~
    Configuration Failed
    
    One or more configuration settings failed. Completed configuration settings will not be rolled back. Resolve the problem and run this configuration wizard again. The following contains detailed information about the failure:
    
    Failed to create sample data.
    An exception of type System.ArgumentException was thrown.
    Additional exception information: The SDDL string contains an invalid sid or a sid that cannot be translated.
    Parameter name: sddlForm
    
    To diagnose the problem, review the application event log and the configuration log file located at:
    C:\Program Files\Common Files\microsoft shared\Web Server Extensions\15\LOGS\PSCDiagnostics_12_14_2020_15_34_33_632_1606065702.log
    
    Click Finish to close this wizard.
    ~~~

    * FIX: Share Analytics_GUID dir with Everyone with Full control (maybe could be fine grained, but fine graining permissions wasn't tested)
      * Right click on folder below and select -> Sharing -> Advanced Sharing... -> Share this folder (check), Permissions: Full Control for Everyone
      * C:\Program Files\Windows SharePoint Services\15.0\Data\Analytics_GUID
1. Run SharePoint 2013 Produts Configuration Wizard again. It should go through.
1. One should be able to access SharePoint locally now http://machine-name

# Configuring SharePoint
* Locally in the VM http://machine-name SharePoint opens nicely in the browser.
* Externally with http://external-ip SharePoint browser gives error:
      
      401 UNAUTHORIZED

* Create A Record in DNS management

      x.y.w.z sharepoint2013foundation.domain.com


1. Add site binding to IIS (maybe not needed)
      1. Open IIS Manager
      1. Select Sites from left "Connections" menu
      1. Select "SharePoint - 80" on the middle "Sites" menu
      1. Click Bindings... on the right "Actions" menu

      ~~~
      Type: http
      IP address: All Unassigned
      Port: 80
      Host name: sharepoint2013foundation.domain.com
      ~~~
1. Add to trusted sites ( maybe not needed, probably wasn't even done )
      1. Open Internet Properties
      1. Security -> Trusted Sites -> Sites
      1. There should be http://sharepoint2013foundation
      1. Add http://sharepoint2013foundation.domain.com

1. Open SharePoint 2013 Central Administration
      1. System Setttings
      1. Configure alternate access mappings
      1. Alternate Access Mapping Collection (Show All), click downward arrow and select Change Alternate Access Mapping Collection
      1. Select SharePoint - 80
      1. Add Internal URLs

         https://sharepoint2013foundation.domain.com:443
         Zone Internet

         http://sharepoint2013foundation.domain.com:80
         Zone Intranet

      1. Check that in "Public URL for Zone" the protocols are correct. These can be configured via "Edit Public URLs"

### Service configurations
#### Automattic start for service SharePoint Administration
* Change service startup from Manual to Automatic for **SharePoint Administration**. Otherwise there will be errors in Windows Event Viewer.
    ~~~
    Application Server job failed for service instance Microsoft.Office.Server.Search.Administration.SearchServiceInstance (2ab24d1d-c450-4707-824d-f0b5ce70fdf0).

    Reason: This operation uses the SharePoint Administration service (spadminV4), which could not be contacted.  If the service is stopped or disabled, start it and try the operation again.

    Technical Support Details:
    System.InvalidOperationException: This operation uses the SharePoint Administration service (spadminV4), which could not be contacted.  If the service is stopped or disabled, start it and try the operation again.
       at Microsoft.Office.Server.Search.Administration.SearchServiceInstance.Synchronize()
       at Microsoft.Office.Server.Administration.ApplicationServerJob.ProvisionLocalSharedServiceInstances(Boolean isAdministrationServiceJob)
    ~~~

#### AppFabric Caching Service, Access denied error
* Starting service AppFabric Caching Service pop-ups error:

    ~~~
    Error:
    Windows could not start the AppFabric Caching Service service on Local Computer
    Error 5: Access is denied.
    ~~~
* Fix:
  * Source https://stackoverflow.com/a/7342679/3498768
  * Add NETWORK SERVICE with "Read & execute" and "Read" permissions for
  * C:\Program Files\AppFabric 1.1 for Windows Server\DistributedCacheService.exe.config
* This was also done, but it's not completely sure if this fixed any issues.
    * Source http://kancharla-sharepoint.blogspot.com/2012/07/service-running-under-network-service.html
    * Open "SharePoint 2013 Management Shell" in administrator mode.
    ~~~
    cd "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\15\BIN"
    psconfig.exe -cmd Configdb create SkipRegisterAsDistributedCacheHost

    SharePoint Products Configuration Wizard version 15.0.4569.1503. Copyright (C) M
    icrosoft Corporation 2012. All rights reserved.

    Performing configuration task 1 of 3
    Initializing SharePoint Products configuration...

    Successfully initialized the SharePoint Products configuration.

    Performing configuration task 2 of 3
    Creating the configuration database...

    Successfully created the configuration database.

    Performing configuration task 3 of 3
    Finalizing the SharePoint Products configuration...

    Successfully completed the SharePoint Products configuration.

    Total number of configuration settings run: 3
    Total number of successful configuration settings: 3
    Total number of unsuccessful configuration settings: 0
    Successfully stopped the configuration of SharePoint Products.
    Configuration of the SharePoint Products has succeeded.
    ~~~    

## Configuring HTTPS
1. PowerShell 7 was beign used. It should be already installed in new Windows 2012 R2 installations.
   * https://github.com/PowerShell/PowerShell
1. Install Posh-ACME for retrieving a cert
   * https://github.com/rmbolger/Posh-ACME
1. Run in PowerShell

   ~~~
   Install-Module -Name Posh-ACME -Scope AllUsers
   Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
   Import-Module Posh-ACME
   ~~~

1. Generate CSR in IIS
   1. Open IIS Manager
   1 . Click root (server name) of the configuration below Start Page
   1. Double click Server Certificates
   1. On the right Actions menu select Create Certificate Request...
      *  Distinguished Name Properties
         * Fill the details Common name is the FQDN
      * Cryptographic Service Provider Properties
         * Cryptographic service provider: Microsoft RSA SChannel Cryptographic Provider
         * Bit length: 2048
         * File name: C:\01-install\sharepoint_csr_2020_12_15.txt

1. Run in PowerShell 7
   ~~~
   $email = 'email@domain.com'
   $csrpath = 'C:\01-install\sharepoint_csr_2020_12_15.txt'
   New-PACertificate -Contact $email -CSRPath $csrpath -AcceptTOS
   ~~~
   * Output path is %userprofile%\AppData\Local\Posh-ACME\
1. Import to Web Hosting in Certificate store:
   1. Open mmc.exe
   1. Add/snapin Certificates (Local Computer)
   1. Right click Web Hosting and select All Tasks -> Import... select fullchain.cerr
1. Enable cert in IIS
   1. Select site SharePoint - 80
   1. Bindings...
   1. Add...
   ~~~
   Type: https
   IP address: All Unassigned
   Port: 443
   Host name: sharepoint2013foundation.domain.com
   Require Server Name Indication: unchecked
   SSL certificate: selecte the new imported cert
   ~~~
