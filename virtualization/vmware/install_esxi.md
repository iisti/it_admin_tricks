# Install ESXi
* Enable all network links in DCUI (if multiple NICs)
* Enable ESXi SSH and Shell in DCUI
* Set hostname in shell
  * esxcli system hostname set --host=hostname
  * Source: https://kb.vmware.com/s/article/1010821   
* In WebGUI
  * Assing license
  * Add another uplink in vSwitch
  * Enable SSH in firewall (in and out)
  * Setup NTP service for time, pools for Austria:
    * 0.at.pool.ntp.org,1.at.pool.ntp.org,2.at.pool.ntp.org,3.at.pool.ntp.org

## Adding another vSwitch with another vmkernel
* One can add another vSwitch and vmkernel with management service for high availability.
    ~~~
    esxcli network vswitch standard add -v vSwitch1
    esxcli network vswitch standard portgroup add -p "Management-failover" -v vSwitch1
    esxcli network vswitch standard portgroup set -v 555 -p "Management-failover"
    esxcli network vswitch standard uplink add -u vmnic1 -v vSwitch1
    esxcli network ip interface add -i vmk1 -p "Management-failover"
    esxcli network ip interface ipv4 set -i vmk1 -I 192.168.2.3 -N 255.255.255.192 -g 192.168.2.1 -t static
    esxcli network ip interface tag add -i vmk1 -t "Management"
    ~~~
