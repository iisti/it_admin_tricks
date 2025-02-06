# Updating ESXi with Zip file
1. Download patch https://my.vmware.com/group/vmware/patch
    ~~~
    ESXi670-202004001
    Product:ESXi (Embedded and Installable) 6.7.0
    Download Size:340.7 MB
    ~~~
1. Check profile name by clicking *Build Number* and also note the *sha1sum*
1. SCP or copy other way the zip update file to ESXi
1. Check integrity of the file
    ~~~
    sha1sum ESXi670-202004001.zip
    dd70d556cf8c550ab324c555974302975749fe48  ESXi670-202004001.zip
    ~~~
1. Put the ESXi into maintenance mode or shutdown all VMs
1. Run update with the *Image Profile Name* which can be found in *Build Number* page, in this case *ESXi-6.7.0-20200403001-standard*
    * If you're running old hardware, add parameter `--no-hardware-warning` to the command below, so that the installation goes through.
    ~~~
    esxcli software profile update -p ESXi-6.7.0-20200403001-standard -d /vmfs/volumes/datastore1/ESXi670-202004001.zip

    Update Result
       Message: The update completed successfully, but the system needs to be rebooted for the changes to be effective.
       Reboot Required: true
       VIBs Installed: VMW_bootbank_bnxtnet_20.6.101.7-24vmw.670.3.73.14320388, ...
    ~~~
1. Reboot
1. SSH and check build version
    ~~~
    vmware -vl
    VMware ESXi 6.7.0 build-15820472
    VMware ESXi 6.7.0 Update 3
    ~~~

* Source: https://www.aligrant.com/web/blog/2019-06-25_vsphere_67_errno_28_no_space_left_on_device__part_2
