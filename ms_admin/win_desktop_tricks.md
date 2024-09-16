# Windows Desktop Instructions

## Windows 11 disable Activity history

Settings -> Privacy & Security -> Activity history -> Disable Store my activity history on this device.``

## Install Windows 10 with USB stick

### Create installation media for Windows
* Windows: Create USB installation media - Windows 10, 64-bit, English
    * Rufus is great!
* Mac: Create a USB installation Media with Mac in terminal

    ~~~
    This doesn't seem to work with the newest Win 10 version 5.11.2019

    # Check which disk is USB disk
    diskutil list
    # Format the USB stick, use ExFat, MS-DOS doesn't support files over 4GB and there's install.wim which is over 4GB. 
    diskutil eraseDisk ExFat "WIN10" GPT disk#
    # Mount Windows Image
    hdiutil mount ~/Downloads/your_windows_10_image.iso
    # Copy data from Windows image to the USB
    cp -rpv /Volumes/ESD-ISO/* /Volumes/WIN10/
    # Unmount Windows image
    hdiutil unmount /Volumes/ESD-ISO
    ~~~

* Add some configuration to the ISO for forcing Windows Pro installation. At least clean installation of one Lenovo installed Home version without asking anything.
  * Source: https://www.askvg.com/fix-cant-select-windows-10-pro-edition-during-clean-installation/
  * Create ei.cfg in Sources folder with content:
  ~~~
  [EditionID]
  Professional
  [Channel]
  Retail
  ~~~

### Create unattended installation media for Win10
* ADK download for Windows 10
   * Install only Deployment Tools ~100MB
   * https://support.microsoft.com/en-us/windows/adk-download-for-windows-10-2a0b7ff2-79b7-b989-f727-43ae506e36ad

* Source of instructions: https://www.windowscentral.com/how-create-unattended-media-do-automated-installation-windows-10

#### Check available versions in admin PowerShell
~~~
# A variable for storing path into the Windows sources directory  
$path_win_sources="C:\Users\iisti\Documents\win10_21h1\sources"

# Check available Windows versions
dism /get-wiminfo /wimfile:$path_win_sources\install.esd

Deployment Image Servicing and Management tool
Version: 10.0.19041.844

Details for image : C:\Users\iisti\Documents\win10_21h1\sources\install.esd

    Index : 1
    Name : Windows 10 Home
    Description : Windows 10 Home
    Size : 14 792 353 972 bytes

    Index : 2
    Name : Windows 10 Home N
    Description : Windows 10 Home N
    Size : 14 016 607 690 bytes

    Index : 3
    Name : Windows 10 Home Single Language
    Description : Windows 10 Home Single Language
    Size : 14 795 189 589 bytes

    Index : 4
    Name : Windows 10 Education
    Description : Windows 10 Education
    Size : 15 046 065 741 bytes

    Index : 5
    Name : Windows 10 Education N
    Description : Windows 10 Education N
    Size : 14 277 676 117 bytes

    Index : 6
    Name : Windows 10 Pro
    Description : Windows 10 Pro
    Size : 15 043 016 056 bytes

    Index : 7
    Name : Windows 10 Pro N
    Description : Windows 10 Pro N
    Size : 14 271 923 209 bytes

    The operation completed successfully.

# Choose Windows version by choosing correct Index. In this example Index 6, Windows 10 Pro was chosen
dism /Export-Image /SourceImageFile:$path_win_sources\install.esd /SourceIndex:6 /DestinationImageFile:$path_win_sources\install.wim /Compress:Max /CheckIntegrity
~~~

* One can check information of the customizations from this link https://docs.microsoft.com/en-us/windows-hardware/customize/desktop/unattend/

#### Customize the installation image
1. Open Windows System Image Manager
    * Make sure you're using correct architecture amd64 and not wow64!
        * At least in these instructions there's no need for wow64 = 32 bit component for 64 bit OS.
1. Select File -> Select Windows Image -> Select the install.wim from the path defined in previous step.
    1. If there's a pop-up about a missing catalog file, click yes to create one.
1. Right click on Select a Distribution Share -> Create a Distrubution Share...
    1. Create new folder for distributions
    1. Select the new distribution share by clicking it.
1. Right click on Answer File -> New Answer File...
1. Configure keyboard settings and UI language with pass "1 windowsPE"
    1. Under the Windows Image section select -> Windows 10 Pro -> Components -> amd64_Microsoft-Windows-International-Core-WinPE -> SetupUILanguage, right click -> Add Setting to Pass 1 windowsPE
    1. Under Answer File in "1 windowsPE" in amd64_Microsoft-Windows-International-Core-WinPE
        * Check input profiles from https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/default-input-locales-for-windows-language-packs
        * Locale infos: https://docs.microsoft.com/en-us/windows-hardware/customize/desktop/unattend/microsoft-windows-international-core

        ~~~
        InputLocale: de-AT # specifies the input language and the method for input devices, such as the keyboard layout.
        SystemLocale: en-US # specifies the default language to use for non-Unicode programs.
        UILanguage: en-US # specifies the default system language that is used to display user interface (UI) items (such as menus, dialog boxes, and Help files).
        UserLocale: de-AT # specifies the per-user settings used for formatting dates, times, currency, and numbers in a Windows installation.
        ~~~

        * Check the current InputLocale from your machine via PowerShell

            ~~~
            # In PowerShell 7 core one needs to import module for the check
            Import-Module -Name International -UseWindowsPowerShell -Verbose
            Get-WinUserLanguageList
                LanguageTag     : en-AT
                Autonym         : English (Austria)
                EnglishName     : English
                LocalizedName   : English (Austria)
                ScriptName      : Latin
                InputMethodTips : {2000:0000040B, 2000:00000407}
                Spellchecking   : True
                Handwriting     : False
            ~~~

        * Check the current SystemLocale

            ~~~
            Get-WinSystemLocale

                LCID             Name             DisplayName
                ----             ----             -----------
                1033             en-US            Englisch (Vereinigte Staaten)
            ~~~

    1. SetupUILanguage
        ~~~
        UILanguage: en-US
        ~~~

1. Configure installation settings
    1. Under the Windows Image section select -> Windows 10 Pro -> Components -> amd64_Microsoft-Windows-Setup -> DiskConfiguration -> Disk, right click -> Add Setting to Pass 1 windowsPE
    1. Under Answer File in "1 windowsPE" in DiskConfiguration
        ~~~
        WillShowUI: OnError
        ~~~
        * If this is left empty, the installation process will stop.
    1. In Disk

        ~~~
        DiskID: 0
        WillWipeDisk: true
        ~~~
    1. UEFI only
        1. Creating and modifying partitions
            1. Right click on CreatePrtitions -> Insert New CreatePartition
                * Repeat 3 times, so you have 4 partitions
            1. Configure the 1st partition, Windows Recovery (WinRE) partition:

                ~~~
                Extend: false
                Order: 1
                Size: 500
                Type: Primary
                ~~~

            1. Configure the 2nd partition, EFI partition:

                ~~~
                Extend: false
                Order: 2
                Size: 100
                Type: EFI
                ~~~

            1. Configure the 3rd partition, Microsoft reserved partition (MSR):

                ~~~
                Extend: false
                Order: 3
                Size: 16
                Type: MSR
                ~~~

            1. Configure the 4th partition, Windows partition:

                ~~~         
                Extend: true
                Order: 4
                Type: Primary
                ~~~

        1. Configure file format and partition properties
            1. Under Answer File in "1 windowsPE" in DiskConfiguration
            1. Right click on ModifyPartitions -> Insert ModifyPartition
                * Repeat 3 times, so you have 4 ModifyParition options
            1. Configure the 1st ModifyPartition for Windows Recovery (WinRE) partition:
                ~~~      
                Format: NTFS
                Label: WinRE
                Order: 1
                PartitionID: 1
                TypeID: DE94BBA4-06D1-4D40-A16A-BFD50179D6AC
                ~~~
            1. Configure the 2nd ModifyPartition for EFI partition:
                ~~~
                Format: FAT32
                Label: System
                Order: 2
                PartitionID: 2
                ~~~
            1. Configure the 3rd ModifyPartition for Microsoft reserved partition (MSR) partition:
                ~~~
                Order: 3
                PartitionID: 3
                ~~~
            1. Configure the 4th ModifyPartition for Windows 10 installation:
                ~~~
                Format: NTFS
                Label: Windows
                Letter: C
                Order: 4
                PartitionID: 4
                ~~~
    1. Configure where to install Windows 10
        1. Under the Windows Image section select -> Windows 10 Pro -> Components -> amd64_Microsoft-Windows-Setup -> ImageInstall -> OSImage -> InstallTo, right click -> Add Setting to Pass 1 windowsPE
        1. Under Answer File in "1 windowsPE" in InstallTo
            ~~~
            DiskID: 0
            PartitionID: 4
            ~~~
            * 1st disk, 4th partition
    1. Set time-zone
        1. Under the Windows Image section select -> Windows 10 Pro -> Components -> amd64_Microsoft-Shell-Setup -> OEMInformation, right click -> Add Setting to Pass 4 specialize 
        1. Under Answer File in "4 specialize" in amd64_Microsoft-Shell-Setup, not in OEMInformation
            ~~~
            TimeZone: W. Europe Standard Time
            ~~~

            * One can check current time zone via PowerShell
                ~~~
                Get-TimeZone

                    Id                         : W. Europe Standard Time
                    DisplayName                : (UTC+01:00) Amsterdam, Berlin, Bern, Rome, Stockholm, Vienna
                    StandardName               : W. Europe Standard Time
                    DaylightName               : W. Europe Summer Time
                    BaseUtcOffset              : 01:00:00
                    SupportsDaylightSavingTime : True
                ~~~
            * To list all time zones
                ~~~
                Get-TimeZone -ListAvailable
                ~~~

    1. Configure oobeSystem (out-of-box experience)
        * Includes additional language settings, accept the licensing agreement, create a user account, and more.
        1. Under the Windows Image section select -> Windows 10 Pro -> Components -> amd64_Microsoft-Windows-International-Core, right click ->  Add Setting to Pass 7 oobeSystem
            ~~~
            InputLocale: de-AT
            SystemLocale: en-US
            UILanguage: en-US
            UserLocale: de-AT
            ~~~

        1. Under the Windows Image section select -> Windows 10 Pro -> Components -> amd64_Microsoft-Shell-Setup -> OOBE, right click ->  Add Setting to Pass 7 oobeSystem
            * amd64_Microsoft-Shell-Setup
                ~~~
                TimeZone: W. Europe Standard Time
                ~~~
            * OOBE   
                ~~~
                HideEULAPage: true
                HideOEMRegistrationScreen: true
                HideOnlineAccountScreens: true
                HideWirelessSetupinOOBE: true
                ProtectYourPC: 1
                ~~~
                * While most settings are self-explanatory, you'll notice that the ProtectYourPC setting is also configured to define how the express settings should be handled. Using the value of 1, you're telling the setup to enable the express settings using the default preferences.

        1. Under the Windows Image section select -> Windows 10 Pro -> Components -> amd64_Microsoft-Shell-Setup -> UserAccounts -> LocalAccounts, right click ->  Add Setting to Pass 7 oobeSystem
            1. Under Answer File in "7 oobe" in amd64_Microsoft-Shell-Setup -> UserAccounts -> LocalAccounts, right click, Insert New LocalAccount
                ~~~
                Description: Local administrator
                DisplayName: ladmin
                Group: Administrators
                Name: ladmin
                ~~~
                1. Select Password component and add password. You'll see it in plaintext, but it will be encrypted.

        1. Under the Windows Image section select -> Windows 10 Pro -> Components -> amd64_Microsoft-Windows-TerminalServices-LocalSessionManager, right click -> Add Setting to Pass 4 specialize
            * Allow RDP to the machine
            * Under Answer File in "4 specialize" in amd64_Microsoft-Windows-TerminalServices-LocalSessionManager
                ~~~
                fDenyTSConnections: false
                ~~~
        1. Under the Windows Image section select -> Windows 10 Pro -> Components -> amd64_Networking-MPSSVC-Svc -> FirewallGroups -> FirewallGroup right click -> Add Setting to Pass 4 specialize
           ~~~
           Active: true
           Group: @FirewallAPI.dll,-28752
           Key: RemoteDesktop
           Profile: all
           ~~~
           * Group ID source: https://docs.microsoft.com/en-us/windows-hardware/customize/desktop/unattend/networking-mpssvc-svc-firewallgroups
1. Define the product key
    * This is required for the installation to start even though the machine would have hardware Windows key. If no product key is defined, there will be error:
        ~~~
        Windows cannot read the <ProductKey> setting from the unattend answer file.
        ~~~
    1. Under the Windows Image section select -> Windows 10 Pro -> Components -> amd64_Microsoft-Windows-Setup -> UserData -> ProductKey, right click -> Add Setting to Pass 1 windowsPE
        1. Under UserData
            ~~~
            AcceptEula: true
            ~~~
        1. Under UserData -> ProductKey
            ~~~
            Key: VK7JG-NPHTM-C97JM-9MPGT-3V66T
            ~~~
            * Check RTM Generic Key (retail) https://www.tenforums.com/tutorials/95922-generic-product-keys-install-windows-10-editions.html 
            * Check KMS key from https://docs.microsoft.com/en-us/windows-server/get-started/kms-client-activation-keys
1. Remove unedited components, at least these should be found:
    ~~~
    4 specialize -> amd64_Microsoft-Shell-Setup -> OEMInformation
    7 oobeSystem -> amd64_Microsoft-Shell-Setup -> OOBE -> VMModeOptiizations
    ~~~
1. Validate the Answer File
    * Select the Answer File and select Tools -> Validate Answer File
        ~~~
        Messages section should show: "No warnings or errors"
        ~~~
1. Save the Answer File by selecting File -> Save Answer File as...
    * Name: autounattend.xml
1. Create USB installation media and copy the file into the root of the installation media.

## After installation configurations
* Rename computer in PowerShell
    ~~~
    Rename-Computer -NewName "vm01"
    ~~~
* Join AD
    ~~~
    Add-Computer -DomainName Domain01 -Server DC01 -Restart 
    ~~~
* Check chocolatey script from [chocolatey.md](chocolatey.md)

* Set time zone
   * Run timedate.cpl as administrator
   * Or in PowerShell
      ~~~
      Get-TimeZone -ListAvailable | where DisplayName -like "*Vienna*"
          Id                         : W. Europe Standard Time
          DisplayName                : (UTC+01:00) Amsterdam, Berlin, Bern, Rome, Stockholm, Vienna
          StandardName               : W. Europe Standard Time
          DaylightName               : W. Europe Daylight Time
          BaseUtcOffset              : 01:00:00
          SupportsDaylightSavingTime : True

      Set-TimeZone -Name "W. Europe Standard Time"
      ~~~

## Check if computer is part of AD
* Run in PowerShell 5.1
   ~~~
   test-computersecurechannel
   ~~~
   * PowerShell 7 requires module import before the command works
      ~~~
      import-module Microsoft.PowerShell.Management -UseWindowsPowerShell
      ~~~
* Answer if machine is not part of AD
   ~~~
   test-computersecurechannel : Cannot verify the secure channel password for the local computer. The local computer is
   not currently part of a domain.
   At line:1 char:1
   + test-computersecurechannel
   + ~~~~~~~~~~~~~~~~~~~~~~~~~~
       + CategoryInfo          : InvalidOperation: (computer71:String) [Test-ComputerSecureChannel], InvalidOperationException
       + FullyQualifiedErrorId : ComputerNotInDomain,Microsoft.PowerShell.Commands.TestComputerSecureChannelCommand
   ~~~
## Check computer domain
* Run in PowerShell
   ~~~
   systeminfo | findstr /B "Domain"
   ~~~

## Disable reboot after Win updates
* If there's a Win 10 machine which is hosting something, it's bad if the OS decides to restart by itself.
* One can disable automatic restart by renaming files named Reboot in `%windir%\System32\Tasks\Microsoft\Windows\UpdateOrchestrator`
    * For example rename *Reboot_AC* -> *Reboot_AC.old*

## Enable Bitlocker
1. gpedit.msc
   1. Computer Configuration
   1. Administrative Templates
   1. Windows Components
   1. Bitlocker Drive Encryption
   1. Operating System Drives
   1. Require additional authentication at startup
      * All to "Allow..."
1. Search in Windows for "Manage Bitlocker"
   1. Click "Turn Bitlocker On"
   1. Select "Enter a PIN (recommended)"
   1. Save backup recovery key to file, USB stick
