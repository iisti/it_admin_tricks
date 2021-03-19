# RDP to Windows 10 VM running on VirtualBox
* These instructions were tested on Mac Catalina 10.15.4 and VirtualBox 6.1.8

## VirtualBox instructions
1. Install VirtualBox (6.1.8 was the latest version on 6.2.2020)
    * https://www.virtualbox.org/wiki/Downloads
    * Give all permissions required by the software
1. Start VirtualBox
1. If there's ready made Win10 VM, click Add
    * Select VM file <vm-name>.vbox
    * The file format is .vbox if the VM has been created with VirtualBox
    * If the VM is in ova/ovf format select Import instead of Add
1. In the added/imported/created VM's settings check:
    * Network -> Adapter1 = NAT (this is default setting)
    * If RDP is required:
      * Network -> Adapter1 -> Port Forwarding:
        * Name: Rule1
        * Protocol: TCP
        * Host IP: can be left empty or put 127.0.0.1
        * Host Port: 5530
        * Guest IP: 10.0.2.15 (this is default VM IP by VirtualBox)
        * Guest Port: 3389
        * Now one can connect to the VM with Mac's "Microsoft Remote Desktop" app (available in App Store).
   
1. Start the VM
    * When connecting locally with RDP, use settings:
      * 127.0.0.1:5530
