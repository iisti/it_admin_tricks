# Script for backing up Hyper-V VMs

* Notice that one needs both to give permissions to both user and machine if one wants to export/backup into network drive.
  * https://morgansimonsen.com/2009/03/22/how-to-export-a-virtual-machine-directly-to-a-network-share/

## How to use
* Give parameters `backup_path` and `vm_status`  `< all | running | off >`
    ~~~
    .\backup_hyper_v_vms.ps1 -backup_path "D:\backup\" -vm_status "all"
    ~~~

## Export / Backup just one VM
* One can easily export one VM with the normal PowerShell commands.
    ~~~
    Export-VM -Path $backup_path -Name $vm.name
    
    # One can add also option, if required:
      -CaptureLiveState CaptureDataConsistentState
    ~~~ 
