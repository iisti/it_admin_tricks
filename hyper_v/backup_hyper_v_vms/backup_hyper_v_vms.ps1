# This script has been tested only with PowerShell 7.1

param ($backup_path, $vm_status, $conf)

# Function for parsing conf.ini
# Source: https://serverfault.com/a/1052846/323362
function Get-IniContent ($filePath)
{
    $ini = @{}
    switch -regex -file $FilePath
    {
        "^\[(.+)\]" # Section
        {
            $section = $matches[1]
            $ini[$section] = @{}
            $CommentCount = 0
        }
        "^(;.*)$" # Comment
        {
            $value = $matches[1]
            $CommentCount = $CommentCount + 1
            $name = "Comment" + $CommentCount
            $ini[$section][$name] = $value
        }
        "(.+?)\s*=(.*)" # Key
        {
            $name,$value = $matches[1..2]
            $ini[$section][$name] = $value
        }
    }
    return $ini
}

# Function for retrieving Guest OS version.
# Based on https://github.com/iisti/it_admin_tricks_private/blob/master/virtualization/hyper_v/get_guest_os_ps_71.ps1
function Get-GuestOS ($vm_name)
{
    # Get the virtual machine object
    $query = "Select * From Msvm_ComputerSystem Where ElementName='" + $vm_name + "'"
    $vm = Get-CimInstance -namespace root\virtualization\v2 -query $query -computername $HyperVServer

    # Get associated information
    $vm_info = Get-CimAssociatedInstance -InputObject $vm


    # Select only required information
    $guest_os = $vm_info | Where GuestOperatingSystem | Select -ExpandProperty GuestOperatingSystem

    return $guest_os
}

# Get date for directory name into which the backups are exported
$date_dir = Get-Date -Format "yyyyMMdd"

# If configuration file was given as a parameter.
if ( -Not $conf -eq $null ) {
    # Read configuration from given path
    $conf_obj = Get-IniContent $conf

    $backup_path = -join($conf_obj.data.backup_path, $date_dir)
} 
else {
    if ( $backup_path -eq $null ) {
        throw "No backup_path given as a parameter."
    }
    $backup_path = -join($backup_path, $date_dir)
}

# https://stackoverflow.com/questions/5466329/whats-the-best-way-to-determine-the-location-of-the-current-powershell-script
$log_path = -join("$PSScriptRoot/logs/hyper_v_backup_", $(hostname), "_", $(Get-Date -Format "yyyyMMdd_HHmmss"),".log")

# Logging
# https://stackoverflow.com/a/60663349/3498768
Start-Transcript -Path $log_path

# UTC date for logs
function Get-Date-UTC { (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss.fffK") }

Write-Host (Get-Date-UTC) "Backing up Hyper-V VMs. Attention! Logging is done in UTC timestamps."
if ( -Not $conf_obj -eq $null ) { Write-Host (Get-Date-UTC) "Using configuration file." }
Write-Host (Get-Date-UTC) "Backup path: $backup_path"
Write-Host (Get-Date-UTC) "Backing VMs with status: $vm_status"

# Create array of Hyper-V VMs
$vms = get-vm


function Export-VM-With-Status ($vm) 
{
        $guest_os = Get-GuestOS $vm.name
        
    
        # Guest OS is empty with Linux VMs (at least CentOS 7/8 and Debian 9/10)
        if ( -Not $guest_os -eq $null ) {
            Write-Host (Get-Date-UTC) "GuestOS" $guest_os 
        }
        
        Write-Host (Get-Date-UTC) "Exporting " $vm.name

        # Windows 2003 server doesn't support parameter -CaptureLiveState
        if ($guest_os -eq "Microsoft Windows Server 2003") {
            Write-Host (Get-Date-UTC) "VM Guest OS: Windows Server 2003. Exporting without parameter -CaptureLiveState"
            Export-VM -Path $backup_path -Name $vm.name
        }
        elseif ($guest_os -eq $null) {
            Write-Host (Get-Date-UTC) "VM Guest OS is empty. VM is probably Linux. Exporting without parameter -CaptureLiveState"
            Export-VM -Path $backup_path -Name $vm.name
        }
        else {
            Export-VM -CaptureLiveState CaptureDataConsistentState -Path $backup_path -Name $vm.name
        }
}

# Backup VMs with certain vm_status: all, running, off
foreach ($vm in $vms)
{
    if ( $vm_status.ToLower() -eq "all" ) {
        Export-VM-With-Status( $vm )
    }
    elseif ($vm.state -eq $vm_status) {
        Export-VM-With-Status( $vm )
    }

}

Stop-Transcript
