
# OVFtool instructions  

## Exporting with WSL and OVFtool
* These steps were done with WSL 1 (Windows Subsystem for Linux) in Windows 10.
1. Mount in WSL (Windows Subsystem for Linux):
  
    ~~~
    sudo mount -t drvfs '\\server\exported-vms' /exported-vms
    ~~~
1. We're going to export a VM from ESXi local datastore to NFS share. The ESXi has 2 Datastores
    ~~~
    esxi-install
    vms
    ~~~
1. OVFtool export command:
    ~~~
    ovftool -tt="OVF" -dm="thin" -n="vm-name-ovf" "vi://root@esxi/vm-name" "/exported-vms/"
    ~~~

## Import command
~~~ 
sudo ovftool --noSSLVerify --datastore="vms" --network="vms" /mnt/backups/vm.ova vi://root@esxi.doiman.com

Opening OVA source: /mnt/backups/vm.ova
Enter login information for target vi://esxi.domain.com/
Username: root
Password: **************
Opening VI target: vi://root@esxi.doiman.com:443/
Deploying to VI: vi://root@esxi.doiman.com:443/
Transfer Completed
The manifest validates
Warning:
 - No manifest entry found for: 'vm_disk0.vmdk'.
 - No manifest entry found for: 'vm_disk1.vmdk'.
Completed successfully
~~~
