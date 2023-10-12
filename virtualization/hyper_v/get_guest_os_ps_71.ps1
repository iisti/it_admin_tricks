# A PowerShell script for querying Hyper-V Guest OS.
# The script has been tested with PowerShell 7.1.
#
# This script is based on the source below. The original works with PowerShell 5.1.
# https://stackoverflow.com/a/38109287/3498768

# Prompt for the Hyper-V Server to use
$hyper_v_server = Read-Host "Specify the Hyper-V Server to use (enter '.' for the local computer)"

# Prompt for the virtual machine to use
$vm_name = Read-Host "Specify the name of the virtual machine"

# Check if VM exists and is running. This script doesn't work if the VM is stopped.
# Capture error output, source: https://stackoverflow.com/a/66861283/3498768
$vm_not_found = $($vm_state = (Get-VM $vm_name).state) 2>&1


if ($vm_not_found -ne $null) {
    Write-Host "$vm_name VM was not found."
    exit
}

if ($vm_state -eq "Off") {
    Write-Host "Cannot retrieve information of $vm_name. The VM is stopped. Only running VM information can be retrieved."
    exit
}

# Get the virtual machine object
$query = "Select * From Msvm_ComputerSystem Where ElementName='" + $vm_name + "'"
$vm = Get-CimInstance -namespace root\virtualization\v2 -query $query -computername $hyper_v_server

# Get associated information
$vm_info = Get-CimAssociatedInstance -InputObject $vm

Write-Host "Guest information for" $vm_name

# Select only required information
$vm_info | Where GuestOperatingSystem |
    Select -Property GuestOperatingSystem, HostComputerSystemName |
    Format-List *
