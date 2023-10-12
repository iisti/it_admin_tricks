# Configuring Mikrotik IPsec Route/Policy Based VPN <-> GCP

* Mikrotik doesn't support IPsec with BGP properly with Mikrotik RouterOS 6.x, so one must use Route/Policy based routing.
  * Source1 https://forum.mikrotik.com/viewtopic.php?t=142239#p797644
  * Source2 https://forum.mikrotik.com/viewtopic.php?t=161904

## GCP configurations, Classic Cloud VPN gateway
* GCP -> Project -> Hybrid Connectivity -> VPN -> Cloud VPN Gateways -> Create VPN gateway -> To create a Classic VPN click here

| VPN Settings | |
| - | - 
| Name | gcp-europe-north1 |
| Description | VPN between office and GCP
| VPC network | default
| Region | europe-north1
| IP address | x.y.z.108

| Tunnel Settings | |
| - | -
| Name | vpn-tunnel-2-eu-north1
| Description | Tunnel to office.
| Remote peer IP address | Mikrotik external IP
| IKE version | IKEv2
| IKE pre-shared key | Generate and copy
| Policy-based | One can choose Route or Policy based, BGP doesn't work with ROS 6.x |
| Remote network IP ranges | Add Mikrotik LANs which need to be reached from GCP, like 10.10.89.0/24 10.10.80.0/23
| Local IP ranges | default

* **THIS DID NOT WORK!** It was a bit unclear how one can add more Remote network IP ranges afterwards. At least just adding new route didn't work
  * GCP -> Project -> VPC network -> Routes -> Create Route

| Route Settings | |
| - | - |
| Name | vpn-tunnel-2-eu-north1-route-3
| Description | whatever
| Network | default
| Destination IP range | 10.10.69.0/24 
| Priority | 1000
| Instance tags | leave empty
| Next Hop | Specify VPN tunnel -> vpn-tunnel-2-eu-north1

* At least by recreating the tunnel with different **Remote network IP ranges**, one can add more routes.


## Mikrotik configurations
~~~
/ip ipsec profile print
Flags: * - default 
 0 * name="default" hash-algorithm=sha1 enc-algorithm=aes-128 dh-group=modp2048,modp1024 lifetime=1d proposal-check=obey nat-traversal=yes dpd-interval=2m dpd-maximum-failures=5 
 1   name="profile_gcp" hash-algorithm=sha1 enc-algorithm=aes-128 dh-group=modp2048,modp1024 lifetime=10h10m proposal-check=obey nat-traversal=no dpd-interval=2m dpd-maximum-failures=5 

/ip ipsec peer print
Flags: X - disabled, D - dynamic, R - responder 
 0    name="peer_gcp_eu_north1" address=x.y.z.108/32 local-address=w.x.z.18 profile=profile_gcp exchange-mode=ike2 send-initial-contact=yes

/ip ipsec proposal print
Flags: X - disabled, * - default 
 0  * name="default" auth-algorithms=sha1 enc-algorithms=aes-128-cbc lifetime=3h pfs-group=modp1024 

/ip ipsec identity print
Flags: D - dynamic, X - disabled 
 0    peer=peer_gcp_eu_north1 auth-method=pre-shared-key secret="your_pw" generate-policy=no 


/ip ipsec policy print
Flags: T - template, X - disabled, D - dynamic, I - invalid, A - active, * - default 
 0 TX* group=default src-address=::/0 dst-address=::/0 protocol=all proposal=default template=yes 

 1  A  ;;; MGMT <-> GCP eu-north1
       src-address=10.10.89.0/24 src-port=any dst-address=10.166.0.0/20 dst-port=any protocol=all 
       action=encrypt level=unique ipsec-protocols=esp tunnel=yes sa-src-address=w.x.z.18 
       sa-dst-address=x.y.z.108 proposal=default ph2-count=1 

 2  A  ;;; INTERNAL <-> GCP eu-north1
       src-address=10.10.80.0/23 src-port=any dst-address=10.166.0.0/20 dst-port=any protocol=all 
       action=encrypt level=unique ipsec-protocols=esp tunnel=yes sa-src-address=w.x.z.18 
       sa-dst-address=x.y.z.108 proposal=default ph2-count=1 


/ip firewall nat print
Flags: X - disabled, I - invalid, D - dynamic 
 0    ;;; IPSEC NAT Exception
      chain=srcnat action=accept src-address=10.10.89.0/24 dst-address=10.166.0.0/20 log=no log-prefix="" 


 1    ;;; INTERNAL <-> GCP eu north1
      chain=srcnat action=accept src-address=10.10.80.0/23 dst-address=10.166.0.0/20 log=no log-prefix="" 

~~~
