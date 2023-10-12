## How to install Hyper-V 2019 Core on laptop with USB Ethernet adatper
1. Install Hyper-V normally.
    ~~~
    Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All
    ~~~
1. If there's an error that there are no active NICs, do the following
    ~~~
    # Check the InstanceId of the USB adapter
    Get-PnpDevice | select Class, FriendlyName, InstanceId | Where-Object {$_.Class -eq "Net"}

    # A bit more refined command if you know the NIC chip maker.
    Get-PnpDevice | select Class, FriendlyName, InstanceId | Where-Object {$_.Class -eq "NET" -and $_.FriendlyName -like "Realtek*" }

    Class FriendlyName                         InstanceId
    ----- ------------                         ----------
    Net   Realtek USB GbE Family Controller    USB\VID_0BDA&PID_8153\000001000000

    # Enable the device
    Enable-PnpDevice -InstanceId 'USB\VID_0BDA&PID_8153\000001000000'
    ~~~
1. If the network adapter has been recognized, do the following
    ~~~
    # Check name of the network adapter
    Get-NetAdapter
    
    # Activate VLAN tagging if needed. This was actually 1 by default which has VLAN enabled, but on Windows 10 the value needed to be 3
    # to activate VLAN.
    Set-NetAdapterAdvancedProperty -Name "Ethernet" -DisplayName "Priority & VLAN" -RegistryValue 1
    
    # Change the names if wanted.
    New-VMSwitch -name "External" -NetAdapterName "Ethernet" -AllowManagementOs $true
    
    # Check the current VLAN setting for management OS
    Get-VMNetworkAdapterVlan -managementOS

    # If you have management VLAN, set it here.
    Set-VMNetworkAdapterVlan -ManagementOS -Access -VlanID 666
    ~~~
1. In the Hyper-V menu select to configure network, option 8, and configure whatever settings you need.
    * TIP: select DHCP if you want to fetch a new IP.

## Installing AWS CLI on Windows 2019 Core Hyper-V host via PowerShell
* Install AWS CLI
    * https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html
    ~~~
    $msi_file="AWSCLIV2.msi"
    Invoke-WebRequest -Uri https://awscli.amazonaws.com/AWSCLIV2.msi -OutFile $msi_file
    Start-Process -FilePath msiexec -Args "/i $msi_file /passive" -Verb RunAs -Wait
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine")
    rm $msi_file
    ~~~

## How to connect from one Hyper-V Manager to another Hyper-V host
* To connect with Hyper-V manager to another host, enable WinRM (Windows Remote Management) by runnign the command below in PowerShell
    ~~~
    WinRM quickconfig
    ~~~ 
* Enable inboud rules in Windows Firewall
    * Windows Remote Management HTTP-In

* Enable PS-Remoting in administrator PowerShell
    ~~~
    Enable-PSRemoting

    WARNING: PowerShell remoting has been enabled only for PowerShell 6+ configurations and does not affect Windows PowerShell remoting configurations. Run this cmdlet in Windows PowerShell to affect all PowerShell remoting configurations.
    WinRM has been updated to receive requests.
    WinRM service type changed successfully.
    WinRM service started.

    Set-WSManQuickConfig:
    Line |
     121 |                  Set-WSManQuickConfig -force
         |                  ~~~~~~~~~~~~~~~~~~~~~~~~~~~
         | <f:WSManFault xmlns:f="http://schemas.microsoft.com/wbem/wsman/1/wsmanfault" Code="2150859113" Machine="localhost"><f:Message><f:ProviderFault provider="Config provider" path="%systemroot%\system32\WsmSvc.dll"><f:WSManFault xmlns:f="http://schemas.microsoft.com/wbem/wsman/1/wsmanfault" Code="2150859113" Machine="host.domain.com"><f:Message>WinRM firewall exception will not work since one of the network connection types on this machine is set to Public. Change the network connection type to either Domain or Private and try again. </f:Message></f:WSManFault></f:ProviderFault></f:Message></f:WSManFault>
     ~~~

  
