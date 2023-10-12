# Instructions and tricks how to convert from VMware to Hyper-V

### Enable Hyper-V
* https://docs.microsoft.com/en-us/virtualization/hyper-v-on-windows/quick-start/enable-hyper-v

### StarWind V2V Converter
* Download and install StarWind V2V Converter
  * https://www.starwindsoftware.com/starwind-v2v-converter#download

## Converting with StarWind V2V

### Source VM Windows 2008 R2
* ***Uninstall VMware Tools before migration!*** This can be close to impossible after migration, as VMware Tools can give all kind of errors, when trying to uninstall.
* Host Hyper-V is running on Windows 10 Pro Version 21H1 (OS Build 19043.1110)
* Converting a VMware VM which was copied directly from ESXi host into Hyper-V host.
  * If you have network connection between the StarWind machine, Hyper-V host and ESXi, you can convert the VM also straight from ESXi into Hyper-V.
1. Source configurations
    ~~~
    Local VM
        select *-flat.vmdk
    ~~~
1. Destination configurations
    ~~~
    Microsoft Hyper-V Server
        * localhost
        Generation: G1
            * https://docs.microsoft.com/en-us/windows-server/virtualization/hyper-v/plan/should-i-create-a-generation-1-or-2-virtual-machine-in-hyper-v
        CPU count: 2
        Memory: 4096
        OS type: Windows
        Network connection: Default Switch

        Select option for VHD/VHDX image format.
        VHD growable image

            Additional options
            * Activate Windows Repair Mode
     ~~~
1. In Virtual Switch Manager
    ~~~
    Add new network
        External_network for having internet connection
            * Attention, check that you select correct NIC (not WiFi card).
            * Enable VLAN ID for management if the Hyper-V host should have different VLAN than the VMs.
                * Of course VLANs need to be configured in the physical network hardware also (switch, firewall, etc...)
    ~~~  
                
### Source VM Windows 2003 32bit
* ***Uninstall VMware Tools before migration!*** This can be close to impossible after migration, as VMware Tools can give all kind of errors, when trying to uninstall.
* Same process as with Windows 2008 R2 VM.
* If the networking doesn't work, add a Legacy NIC.
* Use this vmguest.iso for installing Hyper-V Integration Services
    * The vmguest.iso has been extracted from Windows 2012 R2 Hyper-V server.
        * The file resides in C:\Windows\system32\vmguest.iso
        * Source for info: https://smudj.wordpress.com/2017/03/02/vmguest-iso-for-older-windows-oses-in-win102016/
    * [vmguest_from_win2012r2_good_for_win2003.iso](vmguest_from_win2012r2_good_for_win2003.iso)
        * SHA256: CD7625406165B9B343B61279FB95BFB09DF36EF76E9A6FF08D0A21CD1E0ABC32
        ~~~
        Hyper-V Integration Services
        6.2.9600.19456
        ~~~

### Source VM CentOS 8 running on ESXi
* ***Uninstall VMware Tools before migration!*** This can be close to impossible after migration, as VMware Tools can give all kind of errors, when trying to uninstall.
* Source https://forums.centos.org/viewtopic.php?f=47&t=72654&start=10
1. Create initial image suitable for Hyper-V on the source VM when it's still running on ESXi. Without doing this the VM will not be able to find boot disks.
    ~~~
    mkinitrd -f -v --with=hid-hyperv --with=hv_utils --with=hv_vmbus --with=hv_storvsc --with=hv_netvsc /boot/initramfs-$(uname -r).img $(uname -r)
    ~~~
1. If copying with local files and not connecting straight to ESXi, convert ***-flat.vmdk***, not ***.vmdk*** with StarWind. Gen 2 worked at least. Gen 1 wasn't tested.
