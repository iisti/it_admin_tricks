# How to pfSense CE AWS machine
* Source: https://github.com/hargut/aws-packer-pfsense


# Creating a Debian 11 virtual machine for running the scripts.
* A Debian 11 VM was created to run the packer scripts, because WSL doesn't easily support VNCviewer to inspect the packing process.
* Remote desktop to Debian 11
  * https://bytexd.com/xrdp-debian/
  ~~~
  sudo apt install xrdp
  ~~~
  * xRDP – Detected issues with Debian 11 – Oh No ! Something has gone wrong….
    * https://c-nergy.be/blog/?p=17113
    * Fix by installing another desktop environment
    ~~~
    sudo apt install task-xfce-desktop
    sudo update-alternatives --config x-session-manager
    sudo update-alternatives --install /usr/bin/x-session-manager x-session-manager /usr/bin/xfce4-session 60
    ~~~

  * Move gnome stuff from xsessions to old, couldn't get xfce to be default desktop otherwise
    ~~~
    mkdir /usr/share/xsessions/old
    mv /usr/share/xsessions/gnome* /usr/share/xsessions/old/
    ~~~

## Install and configure packages
1. Install HashiCorp Packer https://www.packer.io/downloads
    ~~~
    curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
    sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
    sudo apt-get update && sudo apt-get install packer
    ~~~
1. Install qemu-kvm and other packages
    ~~~
    sudo apt install qemu-kvm curl vim git rsync xtightvncviewer ssh
    ~~~ 
    * Just `apt install qemu` wasn't enough, there was error below when trying to run `packer build`
        ~~~
        packer build pfsense-qemu-2.4.2.json
        
        qemu: output will be in this color.

        Build 'qemu' errored after 31 milliseconds 196 microseconds: Failed creating Qemu driver: exec: "qemu-system-x86_64": executable file not found in $PATH

        ==> Wait completed after 31 milliseconds 281 microseconds

        ==> Some builds didn't complete successfully and had errors:
        --> qemu: Failed creating Qemu driver: exec: "qemu-system-x86_64": executable file not found in $PATH

        ==> Builds finished but no artifacts were created.
        ~~~
1. Clone the aws-packer-pfsense repository
    ~~~
    cd ~
    git clone https://github.com/hargut/aws-packer-pfsense.git
    ~~~

## Create package
1. Download pfSense image into input directory
    ~~~
    sha25sum: 3fa30cac9b8519e89a176ca8845a5a9536af0e11226f2ec9bcaf85ebcab40416
    image: pfSense-CE-2.4.2-RELEASE-amd64.iso
    ~~~
1. Copy pfsense-qemu.json for creating an updated version of the file.
    ~~~
    cp pfsense-qemu.json pfsense-qemu-fix.json
    ~~~
1. Replace information in the JSON with sed.
    * Fix the packer JSON sytnax
    ~~~
    # Remove line old syntax line
    sed -i '/"iso_checksum_type": "sha256",/d' pfsense-qemu-fix.json
    # Add sha256: as prefix before the shasum (new packer syntax)
    sed -i 's/3fa30cac9b8519e89a176ca8845a5a9536af0e11226f2ec9bcaf85ebcab40416/sha256:3fa30cac9b8519e89a176ca8845a5a9536af0e11226f2ec9bcaf85ebcab40416/g' pfsense-qemu-fix.json
    ~~~
    * Packing with virtual machine which is not super fast, so there's need to slow down every command.   
    ~~~ 
    sed -i 's/wait5/wait10/g' pfsense-qemu-fix.json
    sed -i 's/wait10/wait20/g' pfsense-qemu-fix.json
    sed -i 's/"boot_wait": "45s"/"boot_wait": "120s"/g' pfsense-qemu-fix.json
    ~~~
1. Run the packer
    ~~~
    packer build pfsense-qemu-fix.json
    ~~~
1. Use command below to check what is happening in during `Typing the boot command over VNC...`
    ~~~
    vncviewer -shared 127.0.0.1:5900
    ~~~

## Upload the image into AWS
1. Edit the scripts / configurations files
    ~~~
    cp ec2-snapshot.sh ec2-snapshot.sh.orig
    sed -i 's/playground/YOUR_PROFILE/' ec2-snapshot.sh
    sed -i 's/ec2-vm-import-3284a153f2ed/YOUR_BUCKET/g' ec2-snapshot.sh

    cp role-policy.json role-policy.json.orig
    cp trust-policy.json trust-policy.json.orig

    sed -i 's/arn:aws:s3:::ec2-vm-import-3284a153f2ed/arn:aws:s3:::YOUR_BUCKET/g' role-policy.json
    sed -i 's/arn:aws:s3:::ec2-vm-import-3284a153f2ed/arn:aws:s3:::YOUR_BUCKET/g' trust-policy.json
    ~~~ 

1. Edit import-role.sh and run it.
    ~~~
    sed -i 's/\${PROFILE}/YOUR_PROFILE/' import-role.sh

    ./import-role.sh
    An error occurred (NoSuchEntity) when calling the DeleteRolePolicy operation: The role with name vmimport cannot be found.
    An error occurred (NoSuchEntity) when calling the DeleteRole operation: The role with name vmimport cannot be found.

    {
        "Role": {
            "Path": "/",
            "RoleName": "vmimport",
            "RoleId": "AROAWZR2CGT42GKQUS2NG",
            "Arn": "arn:aws:iam::467199472889:role/vmimport",
            "CreateDate": "2021-10-11T13:39:37+00:00",
            "AssumeRolePolicyDocument": {
                "Version": "2012-10-17",
                "Statement": [
                    {
                        "Effect": "Allow",
                        "Principal": {
                            "Service": "vmie.amazonaws.com"
                        },
                        "Action": "sts:AssumeRole",
                        "Condition": {
                            "StringEquals": {
                                "sts:Externalid": "vmimport"
                            }
                        }
                    }
                ]
            }
        }
    }
    ~~~

    * If the above is not done, there will be error
        ~~~
        An error occurred (InvalidParameter) when calling the ImportSnapshot operation: The service role vmimport provided does not exist or does not have sufficient permissions
        ~~~

1. Run the script
    ~~~ 
    ./ec2-snapshot.sh qemu

    # If everything goes well, this is shown.
    {
        "ImportTaskId": "import-snap-0343a5b53ca891e48",
        "SnapshotTaskDetail": {
            "DiskImageSize": 0.0,
            "Progress": "0",
            "Status": "active",
            "StatusMessage": "pending",
            "UserBucket": {
                "S3Bucket": "YOUR_BUCKET",
                "S3Key": "pfSense-CE-2.4.2_20211007_070149.vmdk"
            }
        },
        "Tags": []
    }
    ~~~
1. Create AMI from the snapshot
    * What machine types are supported https://docs.netgate.com/pfsense/en/latest/solutions/aws-vpn-appliance/instance-type-and-sizing.html
      ~~~
      aws ec2 --profile YOUR_PROFILE register-image --name "pfsence-ce-2.4.2" --region=eu-west-1 --description "pfsense_for_openvpn_hosting" --block-device-mappings DeviceName="/dev/xvda",Ebs={SnapshotId="
      snap-0725f8d57de87d37a"} --root-device-name "/dev/xvda" --architecture "x86_64" --virtualization-type "hvm"
      ~~~
    * Output
      ~~~
      {
          "ImageId": "ami-093c9c82cad71xxxx"
      }
      ~~~

1. Create pfSense VM by clicking AMI -> Launch an instance
    * Settings
        ~~~
        Enable Auto-Assing Public IP
            Or don't enable and later allocate Elastic IP which can be associated.
        Add a second NIC
        Enable termination protection

        Storage 4 GB gp3

        SG:
        SSH = Custom TCP 6736
        HTTPS = Custom TCP 7373
        ICMP 
        ~~~

    * This warning can be disregarded.
        ~~~
        Warning
        You will not be able to connect to this instance as the AMI requires port(s) 22 to be open in order to have access. Your current security group doesn't have port(s) 22 open.
        ~~~

    * Default credentials for login
        ~~~ 
        admin / pfsense
        ~~~

1. Login into the VM and configure general configuration
    ~~~
    Hostname: vpn01
    Domain: example.com
    Primary DNS Server: 8.8.8.8
    Secondary DNS Server: 8.8.4.4
    Override DNS (Allow DNS servers to be ovverriden by DHCP/PP on WAN): checked

    Time server hostname: 0.pfsense.pool.ntp.org
    Timezone: Europe/Vienna

    Configure WAN Interface
        SelectedType: DHCP

    Configure LAN Interface
        LAN IP Address: dhcp
        Subnet mask 24

    Set admin pw
    ~~~


## Update System
* This error will pop up if pfsense-upgrade package is not installed.
    ~~~
    >>> Updating repositories metadata... 
    pkg-static: Warning: Major OS version upgrade detected.  Running "pkg bootstrap -f" recommended
    Updating pfSense-core repository catalogue...
    Fetching meta.conf: . done
    Fetching packagesite.txz: . done
    Processing entries: . done
    pfSense-core repository update completed. 7 packages processed.
    Updating pfSense repository catalogue...
    pkg-static: Repository pfSense has a wrong packagesite, need to re-create database
    Fetching meta.conf: . done
    Fetching packagesite.txz: .......... done
    Processing entries: 
    pkg-static: Newer FreeBSD version for package php74-shmop:
    To ignore this error set IGNORE_OSVERSION=yes
    - package: 1202504
    - running kernel: 1101001

    pkg-static: repository pfSense contains packages for wrong OS version: FreeBSD:12:amd64
    Processing entries... done
    Unable to update repository pfSense
    Error updating repositories!
    >>> Locking package pkg... done.
    ERROR: It was not possible to determine pfSense-upgrade remote version
    >>> Unlocking package pkg... done.
    Failed
    ~~~
    * FIX: Select 2.4.5 branch and update. Then select 2.5.x and update again.
    * This was also, done before selecting 2.4.5 branch for updating, but maybe this is not actually needed.
        ~~~
        ssh -p 6736 admin@IP
        pkg bootstrap -f
        pkg-static clean -ay; pkg-static install -fy pkg pfSeense-repo pfSense-upgrade
        ~~~
* Allow ping
    ~~~
    pfsense -> Firewall -> Rules -> WAN
    Allow ping/ICMP to WAN address
        For testing purposes allow ICMP in GCP firewall rules to the WAN internal IP.
            Restrict source if required.
        Now ping/ICMP should work.
    ~~~

# Configuring OpenVPN service

## Create certificates
* System -> Certificate Manager -> Create CA and certificates for VPN server and client
* If your create server certificate with FQDN and IP in Certificate Attributes, then you should be able to use either in VPN client configuration as remote destination.

1. CAs
    * Add
    ~~~
    Create / Edit CA
        Descriptive name: vpn01
        Method: Create an internal Certificate Authority
        Key-type: ECDSA
            prime256v1[HTTPS][IPsec][OpenVPN]
        Digest Algorithm: sha256
        Lifetime (days): 3650
        Common Name: internal-ca-01
        Country Code: AT
    ~~~
1. Certificates
    * No need to create a client certificate, the certificate is created when user is created.
    * Add/Sign
    ~~~
    Add/Sign a New Certificate
        Descriptive name: vpn01-server
        Method: Create an internal Certificate Authority
        Key-type: ECDSA
            prime256v1[HTTPS][IPsec][OpenVPN]
        Digest Algorithm: sha256
        Lifetime (days): 3650
        Common Name: vpn.exmaple.com
        Country Code: AT
        
    Certificate Attributes
        Certificate Type: Server  Certificate
        Alternative Names: Add all possible names and IPs.
    ~~~

## Run OpenVPN Wizard (2.5.2)
* pfSense -> VPN -> OpenVPN -> Wizards -> Local User Access
* Certificate Authority: vpn-aws
* Server Certificate: vpn01-server
* Interface: WAN
* Protocol: UDP on IPv4 only
* Local Port: 443 (should be open everywhere)
* Description: Employee VPN
* A lot of defaults...
  * Tunnel Settings
    * Tunnel Network: 10.0.9.0/24 (This is just example network, check that this is not conflicting your existing networks.)
    * Local Network: Subnets that you want to grant access into
    * Concurrent Connections: 10
    * Duplicate Connections: check this if using one username for multiple users.
  * DNS settings
    * DNS default domain: your domain if needed
    * Set internal DNS servers if needed
  * NEXT
    * Check:
      * Traffic from clients to server (Firewall Rule)
      * Traffic from clients through VPN (OpenVPN rule)
      
To be able to export client configurations, browse to System->Packages and install the OpenVPN Client Export package. 
      
## Install openvpn-client-export package
* For exporting VPN settings to clients.
    * pfSense -> System -> Package Manager -> Available Packages -> Search: openvpn-client-export
    * Now there should be option "Client Export" in VPN -> OpenVPN

## Configure Client Export
* pfsense -> VPN -> OpenVPN -> Client Export
* Configuration:
  * Host Name Resolution: Other
  * Host Name: <put a public DNS name> or <IP>
  * Verify Server CN: Automatic
  * Add to Advanced:
      ~~~ 
      #### Routing through GCP VPN ####
      #
      # One can add routes to certain IPs via conf file
      #route x.y.z.w 255.255.255.255
      #
      # Uncomment the line below if you want to redirect all traffic
      # through VPN on Windows/Linux machine.
      # On Mac's Tunnelblick you can do this in the client settings.
      #redirect-gateway def1
      #
      ~~~

## Export client configuration and add certs
* Create user with certificate
  * System -> User Manager -> Users
    * There's check box: Certificate Click to create a user certificate
* Now there should be user which configuration can be exported.
  * Export: pfsense -> VPN -> OpenVPN -> Client Export -> Config File Only
  * The file should be something like this:
      ~~~
      dev tun
      persist-tun
      persist-key
      cipher AES-128-CBC
      ncp-ciphers AES-128-GCM
      auth SHA256
      tls-client
      client
      resolv-retry infinite
      remote vpn01.domain.com 443 udp4
      verify-x509-name "vpn01.domain.com" name
      auth-user-pass
      pkcs12 pfSense-UDP4-443-vpn_cert01.p12
      tls-auth pfSense-UDP4-443-vpn_cert01-tls.key 1
      remote-cert-tls server
      #### Routing through GCP VPN ####
      #
      # One can add routes to certain IPs via conf file
      #route x.y.z.w 255.255.255.255
      #
      # Uncomment the line below if you want to redirect all traffic
      # through VPN on Windows/Linux machine.
      # On Mac's Tunnelblick you can do this in the client settings.
      #redirect-gateway def1
      #
      ~~~

## Add certs to the configuration
* One can edit the configuration file to include all the certificates in it.
* Remove or comment out the lines below from the client configuration:
    ~~~
    pkcs12 pfSense-UDP4-443-vpn_cert01.p12
    tls-auth pfSense-UDP4-443-vpn_cert01-tls.key 1
    ~~~

* Add these lines to the end:
    ~~~
    <ca>
    PUT_CA_CERT
    </ca>
    <cert>
    PUT_USER_CERT
    </cert>
    <key>
    PUT_USER_KEY
    </key>
    key-direction 1
    <tls-auth>
    PUT_SERVER_CERT
    </tls-auth>
    ~~~
* So the full client configuration will be:
    ~~~
    dev tun
    persist-tun
    persist-key
    cipher AES-128-CBC
    ncp-ciphers AES-128-GCM
    auth SHA256
    tls-client
    client
    resolv-retry infinite
    remote vpn01.domain.com 443 udp4
    verify-x509-name "vpn01.domain.com" name
    auth-user-pass
    remote-cert-tls server
    #### Routing through VPN ####
    #
    # One can add routes to certain IPs via conf file
    route x.y.z.w 255.255.255.255
    #
    # Uncomment the line below if you want to redirect all traffic
    # through VPN on Windows/Linux machine.
    # On Mac's Tunnelblick you can do this in the client settings.
    #redirect-gateway def1
    #
    <ca>
    PUT_CA_CERT
    Can be found from: System -> Cert. Manager -> CAs -> Export CA
    </ca>
    <cert>
    PUT_USER_CERT
    Can be found from: System -> Cert. Manager -> Certificates -> VPN user, Export Certificate
    </cert>
    <key>
    PUT_USER_KEY
    Can be found from: System -> Cert. Manager -> Certificates -> VPN user, Export Key
    </key>
    key-direction 1
    <tls-auth>
    PUT_SERVER_CERT
    Can be found from: VPN -> OpenVPN -> Servers -> Click *Edit* of your VPN conf -> Copy: TLS Key
    </tls-auth>
    ~~~
* Install OpenVPN client and enable port 443 from AWS SG.
* Test connection.
* Take a snapshot
* **LAN interface should be disabled!** Otherwise the Web UI address will change intermittently between the IPs.
    * Interfaces -> LAN - > Enable: uncheck
