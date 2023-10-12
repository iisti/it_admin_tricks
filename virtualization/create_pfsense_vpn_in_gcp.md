# How to install pfSense to GCP
* Sources:
  * https://blog.kylemanna.com/cloud/pfsense-on-google-cloud/
  * https://medium.com/@silasthomas/how-to-import-a-pfsense-firewall-into-google-cloud-platform-ad62257a143a
  * How to access LAN via VPN: https://www.informaticar.net/openvpn-on-pfsense-enable-access-to-the-lan-resources/
* These instructions have been tested with Ubuntu WSL (Windows Sub-system Linux) on Windows 10 laptop.

## Get download link for pfSense
* https://www.pfsense.org/download/
~~~
Version: 2.4.5
Architecture: AMD64 (64-bit)
Installer: USB Memstick Installer
Console: Serial
Mirror: closest to you
~~~
* Copy the doownload link

## Creating image
* Download the image, decompress and move it to the required file:

      curl https://nyifiles.pfsense.org/mirror/downloads/pfSense-CE-memstick-serial-2.4.5-RELEASE-amd64.img.gz | gunzip > disk.raw

* Create a tar file in the format Google Cloud expects:

      tar -Sczf pfSense-CE-memstick-serial-2.4.5-RELEASE-amd64.img.tar.gz disk.raw


## Uploading image to Google Cloud Storage
* Instructions for installing gsutil
  * https://cloud.google.com/storage/docs/gsutil_install#deb
* Copy the image to GCS

      gsutil cp pfSense-CE-memstick-serial-2.4.5-RELEASE-amd64.img.tar.gz gs://gcp-projec-name

## Create a new image in GCP
* In GCP -> Compute Engine -> Images -> Create image
  * Source: Cloud Storage file and use the image created in previous step

## Create a new instance for the installer
* In GCP -> Compute Engine -> VM instances -> Create instance
  * Name: pfsense-install-1
  * Bood disk -> Custom: pfsense-245-installer
  * Add another disk: 
    * Name: pfsense-245--clean-install
    * Source type: Blank disk
    * Size: 20 GB
* Start the instance and wait for it to complete start-up.

## Enable serial and connect to it
* Enable serial

      gcloud compute instances add-metadata --project=YOUR_PROJECT_NAME --zone=YOUR_ZONE --metadata=serial-port-enable=1 YOUR_INSTANCE_NAME
* Connect to serial

      gcloud compute connect-to-serial-port --project=YOUR_PROJECT_NAME --zone=YOUR_ZONE YOUR_INSTANCE_NAME

* The VM required reset before installer could be started for some reason.
* Install pfSense to the 20 GB disk, this should work with defaults by just clicking forward.
* After installing stop the pfsense-install-1 instance.

## Create snapshot of new installation
* Create a snapshot of the new pfSense install disk, so it can be used as boot disk
  * Compute Engine -> Disks -> pfsense-245-clean-install -> Create snapshot
    * Name: pfsense-245-image

## Create final pfSense instance
* Compute Engine -> VM instances -> Create instance
  * Boot disk: Snapshots -> pfsense-245-image, 20 GB
  * Add Networking tag: pfsense-vpn
    * Helps configuring firewall rules
  * Networking
    * Reserve static internal IP
    * Reserve static external IP

## Enable and connect to serial console for initial configuration
    gcloud compute instances add-metadata --project=YOUR_PROJECT_NAME --zone=YOUR_ZONE --metadata=serial-port-enable=1 pfsense-vpn
    gcloud compute connect-to-serial-port --project=YOUR_PROJECT_NAME --zone=YOUR_ZONE pfsense-vpn

* Set up VLANs: No
* Interfaces:
  * WAN = vtnet0 (by default the only one)
  * Migh be that one needs to manually write **vtnet0**. The installer is a bit confused as there's no LAN NIC.
  * WAN IP should come via DHCP.

        You can now access the webConfigurator by opening the following URL in your web browser:
                https://10.z.y.x/
  * It's not possible to connect to the public external IP if GCP ports are not opened!
  * With option 8 go to shell and do any necessary configurations.
    * There's need to change interface MTUs GCP has some overhead, this can be done via GUI also.
    * https://cloud.google.com/vpn/docs/concepts/mtu-considerations
    
          ifconfig vtnet0 mtu 1460

## Web UI configurations
* Run the installer.
* Set configuration port to 20443:
  * pfSense -> System -> Admin Access -> TCP port: 20443
  * We're using 443 for VPN, so this makes it more easier to manage the pfSense.
* Set interface MTUs to 1460.

## Edit firewall rules
* pfsense -> Firewall -> Rules -> WAN
* Allow TCP/UDP 443 (HTTPS) to WAN address (or whatever port you have configured for VPN).
* Allow ping/ICMP to WAN address
  * For testing purposes allow ICMP in GCP firewall rules to the WAN internal IP.
    * Restrict source if required.
  * Now ping/ICMP should work.

# Configuring OpenVPN service

## Create certificates
* System -> Certificate Manager -> Create CA and certificates for VPN server and client
* If your create server certificate with FQDN and IP in Certificate Attributes, then you should be able to use either in VPN client configuration as remote destination.

## Run OpenVPN Wizard
* pfSense -> VPN -> OpenVPN -> Wizards -> Local User Access
* Interface: WAN
* Protocol: UDP on IPv4 only
* Local Port: 443 (should be open everywhere)
* Description: Employee VPN
* A lot of defaults...
* Tunnel Network: 10.0.9.0/24 (This is just example network, check that this is not conflicting your existing networks.)
* Local Network: Subnets that you want to grant access into
* Concurrent Connections: 10
* Duplicate Connections: check this if using one username for multiple users.
* DNS default domain: your domain if needed
* Set internal DNS servers if needed
* NEXT
* Check:
  * Traffic from clients to server (Firewall Rule)
  * Traffic from clients through VPN (OpenVPN rule)

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
    #### Routing through GCP VPN ####
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

* Install OpenVPN client and enable port 443 from GCP firwall.
* Test connection.
* Take a snapshot of the VM.

### Skip this section. This actually probably does not need to be done and could be removed from the instructions. It's not completely sure if this section is obsolete, so it has not been removed completely from these instructions.
* Set static route for the office network. This only needs to be done if there's a static VPN between GCP and office.
  * System -> Routing -> Static Routes
    * Add a static route to the office network. The same as was created above.
    * This will add Automatic Rules in Firewall -> NAT -> Outbound, Mode "Automatic". There should be 4 rules:

| Interface | Source | Source Port | Destination | Destination Port | NAT Address | NAT Port | Static Port | Description |
| --------- | ------ | ----------- | ----------- | ---------------- | ----------- | -------- | ----------- | ----------- |
| WAN | Local IPs | * | * | 500 | WAN address | * | static | Auto created rule for ISAKMP |
| WAN | Local IPs | * | * | * | WAN address | * | random | Auto created rule |
| LAN | Local IPs | * | * | 500 | LAN address | * | static | Auto created rule for ISAKMP |
| LAN | Local IPs | * | * | * | LAN address | * | random | Auto created rule |
* Set Default gateway IPv4
  * System -> Routing -> Gateways -> Default gateway IPv4: WAN_DHCP
* ~Set Interfaces -> WAN Static IPv4~ No need to do this. pfSense -> Status -> Gateways shows offline, but Ping 8.8.4.4 still works.
  * IP should be the one which is the static internal reserved IP by GCP.
    * GCP -> Compute Engine -> VM instances, in here the "Internal IP" which is mapped to External IP. This internal IP should be the WAN IP.
  * After setting the static WAN IP, pfSense should show gateway online.
    * pfSense -> Status -> Gateways
