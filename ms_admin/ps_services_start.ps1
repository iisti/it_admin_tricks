# Start services

# Run with command:
# powershell.exe -noprofile -executionpolicy bypass -file c:\01-install\services_start.ps1

# This script has been tested with Windows 2012 R2 and PowerShell 4.0

# Check service names with command
# Get-Service -DisplayName servicename* | Format-List

# PowerShell 4.0 doesn't recognize this command: Set-Service -StartupType AutomaticDelayedStart -Name "servicename"
# so a workaround was required to set services to AutomaticDelayedStart startup type.
function Set-StartupType-Delayed
{
    Param (
        [Parameter(Mandatory=$true,Position=1,HelpMessage="Service Name")]
        [ValidateNotNullOrEmpty()]
        $ServiceName
    )
    if (Test-Path -Path "HKLM:\SYSTEM\CurrentControlSet\Services\$ServiceName") {
        
        Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\$ServiceName" -Name 'DelayedAutostart' -Value '1' -Force
        Write-Output "Is the service delayed $($ServiceName): $((Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\$ServiceName").DelayedAutostart)"
        #Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\$ServiceName" -Name 'Start' -Value '2' -Force
        #Write-Output "Value for $($ServiceName): $((Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\$ServiceName").Start)"
    }
    else {
        Write-Output "Srvice $ServiceName was not found!"
    }
}

# Set the AutomaticDelayedStart in the registry
Set-StartupType-Delayed "servicename"

# Even though StartupType is set to Automatic if the service has been previously AutomaticDelayedStart, then it will be again delayed.
Set-Service -StartupType Automatic -Name "servicename"

# Start the services
Start-Service -Name "servicename"
