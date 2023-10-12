# Configuring Cisco 220 26P

* Example configuration for Cisco 220 26P switch.

* Create General port (trunk port requires an untagged VLAN)
  * https://www.cisco.com/c/dam/en/us/td/docs/switches/lan/csbss/sf220_sg220/command_line_reference/Sx220_CLI_Guide.pdf

## Basic configuration commnds
* List all interface gigabit statuses

      show interfaces status GigabitEthernet 1-26

* Show what macs are connected to which port

      show mac address-table

* Disable/enable interface
~~~
SwitchCBXXXX#show interfaces status GigabitEthernet 4
Port  Name                 Status      Vlan  Duplex  Speed    Type
gi4                        connected   727   a-full  a-1000M  Copper

Port Time Range                       Status
---- -------------------------------- --------
gi4
SwitchCBXXXX#config
interface gi4
shutdown
*Nov 10 2019 17:22:22: %Port-5: GigabitEthernet4 link down
no shutdown
*Nov 10 2019 17:22:39: %Port-5: GigabitEthernet4 link up
~~~

## Check POE
~~~
sw007#show power inline
Power management mode: Port limit mode
Legacy device supports: disabled
Unit Power Status Nominal  Allocated       Consumed Available Usage     Traps
                  Power    Power           Power    Power     Threshold
---- ----- ------ -------- --------------- -------- --------- --------- -------
1    On    Normal 180Watts   6Watts (3%)     6Watts 174Watts  95        disabled

Port State Status     Priority Class   Max.Power (Admin) Device
                                       (mW)
---- ----- ---------- -------- ------- ----------------- ----------------
gi1  Auto  on         low      class0  30000 (30000)     Ieee PD
gi2  Auto  searching  low      N/A     30000 (30000)     N/A
gi3  Auto  searching  low      N/A     30000 (30000)     N/A
gi4  Auto  searching  low      N/A     30000 (30000)     N/A
gi5  Auto  searching  low      N/A     30000 (30000)     N/A
gi6  Auto  searching  low      N/A     30000 (30000)     N/A
gi7  Auto  searching  low      N/A     30000 (30000)     N/A
gi8  Auto  searching  low      N/A     30000 (30000)     N/A
gi9  Auto  searching  low      N/A     30000 (30000)     N/A
gi10 Auto  searching  low      N/A     30000 (30000)     N/A
gi11 Auto  searching  low      N/A     30000 (30000)     N/A
gi12 Auto  searching  low      N/A     30000 (30000)     N/A
gi13 Auto  searching  low      N/A     30000 (30000)     N/A
gi14 Auto  searching  low      N/A     30000 (30000)     N/A
gi15 Auto  searching  low      N/A     30000 (30000)     N/A
gi16 Auto  searching  low      N/A     30000 (30000)     N/A
gi17 Auto  searching  low      N/A     30000 (30000)     N/A
gi18 Auto  on         low      class0  30000 (30000)     Ieee PD
gi19 Auto  searching  low      N/A     30000 (30000)     N/A
gi20 Auto  searching  low      N/A     30000 (30000)     N/A
gi21 Auto  searching  low      N/A     30000 (30000)     N/A
gi22 Auto  searching  low      N/A     30000 (30000)     N/A
gi23 Auto  searching  low      N/A     30000 (30000)     N/A
gi24 Auto  searching  low      N/A     30000 (30000)     N/A
~~~

## Reset to factory
  * Web UI
    * https://www.cisco.com/c/en/us/support/docs/smb/switches/cisco-350-series-managed-switches/smb985-how-to-manually-reboot-or-reset-a-switch.html
  * Via CLI
    * https://www.cisco.com/c/en/us/support/docs/smb/switches/cisco-350-series-managed-switches/smb5559-how-to-manually-reload-or-reset-a-switch-through-the-command.html
  * Run "reload" in shell and press Esc when rebooting. One needs to be connected via serial to see "Startup Menu".

~~~
sw007#reload
System configuration has been modified. Save? [yes/no]:no
Proceed with reload? [confirm]y
Reload confirmed
*May 11 2020 04:35:17: %System-4: System reboot
Restarting system.


BOOT Software Version 1.0.0.6 (Jan 24 2014 - 14:43:52)

                    #                               #
                   ###                             ###
                   ###                             ###
                   ###                             ###
            #      ###      #               #      ###      #
           ###     ###     ###             ###     ###     ###
    #      ###     ###     ###      #      ###     ###     ###      #
   ###     ###     ###     ###     ###     ###     ###     ###     ###
   ###     ###     ###     ###     ###     ###     ###     ###     ###
   ###     ###     ###     ###     ###     ###     ###     ###     ###
    #       #      ###      #       #       #      ###      #       #
                   ###                             ###
                   ###                             ###
                    #                               #


            #######   ###    #######       #######      #####
          #########   ###   ###    ##    #########    #########
         ###          ###    ####       ###          ###     ###
         ###          ###      ###      ###          ###     ###
         ###          ###       ####    ###          ###     ###
          #########   ###   ##    ###    #########    #########
            #######   ###    #######       #######      #####

Networking device with Realtek MIPS CPU core.

CPU:500MHz LXB:200MHz MEM:300MHz
DRAM:  128 MB
SPI-F: 1x32 MB

Switch Model: SG220-26P (Port Count: 26)


MAC Address : 2C:AB:EB:CB:XX:XX




     Startup Menu

[1] Password Recovery Procedure
[2] Restore Factory Defaults
[3] Erase Flash File
[4] Loader Shell
[0] Exit
Enter your choice: Erasing SPI flash...II: Erasing 4096 bytes from 00070000... 100%
Writing to SPI flash...II: Writting 4096 bytes to 00070000... 100%
done


## Booting image from partition ... 1
   Image Name:   1.1.4.5
   Created:      2019-09-19   9:52:53 UTC
   Image Type:   MIPS Linux Kernel Image (gzip compressed)
   Data Size:    7613702 Bytes = 7.3 MB
   Load Address: 70000000
   Entry Point:  8026f000
   Verifying Checksum ...
   Uncompressing Kernel Image ... OK

Starting ...
▒

Generating a SSHv2 default RSA Key.
This may take a few minutes, depending on the key size.

Generating a SSHv2 default DSA Key.
This may take a few minutes, depending on the key size.

Generating a 2048 bit RSA private key
........+++
..................................+++
writing new private key to '/mnt/ssh/ssl_key.pem'
-----
No value provided for Subject Attribute ST, skipped
No value provided for Subject Attribute L, skipped
No value provided for Subject Attribute OU, skipped
~~~

# Set basic confs
* These are done via direct serial connection
~~~
# Set password
config
username cisco privilege 15 secret yourpassword
# Change hostname
config
hostname sw007
# Create VLAN (here management VLAN is created)
vlan 70
name BASE
exit
# Set management VLAN
management-vlan vlan 70
# Set Management VLAN IP
management vlan ip-address 10.10.10.5 mask 255.255.255.0
# Set default gateway
ip default-gateway 10.10.10.1
~~~

## Create LAG/LACP Uplink
~~~
config
interface Port-Channel 1
switchport trunk allowed vlan add 70,721,724,727,844,846,866,878,700
switchport mode trunk uplink
description LACP1
# tpid should be set by default to 0x8100 when mode "trunk uplink" is set,
# but there's also a command to change it:
# switchport vlan tpid 0x8100
exit
~~~

## Add members to LAG/LACP
~~~
# Ports don't need more configuration because the VLAN settings and other are defined by the LAG "port"
# Quite many instructions in the internet configure ports also, but there doesn't seem to be real need.
# On Web GUI it's not even possible to change VLANs of ports which are part of LAG
interface gi25
speed 1000
channel-group 1 mode active
# Port GigabitEthernet25 is added to port-channel Port-Channel1, please ensure the speed/duplex setting on GigabitEthernet25 is correct for the SFP inserted
exit

# Add more the same way if needed
~~~

* Sometimes disable/enable bonding from firewall/other end helps with LACP/LAG problems.

## Time settings
~~~
# Set time, month needs to be written with chars like: "sw007#clock set 09:56:30 may 11 2020"
end
clock set HH:MM:SS month day year
# Set timezone Austria +2
config
clock timezone CET +2
~~~


## Access port for admin
~~~
config
int gi6
switchport mode access
switchport access vlan 70
end
~~~ 

## Create other VLANs
~~~
config
vlan <number>
name <name>

# VLANs in use:
  721           OFFICE_ADMIN         Tagged
  724                 OFFICE         Tagged
  727                  GUEST         Tagged
  844                   ESXI         Tagged
  846                 GUEST2         Tagged
  866                CAMERAS         Tagged
  878               PRINTERS         Tagged
  700               INTERNAL         Tagged
~~~ 
  

## Save configuration 
~~~
# To save the current Running Configuration to the Startup Configuration file, use the
write Privileged EXEC mode command.
sw007#write
Building configuration...
[OK]
~~~

# Port for WiFi Access Point
## Unifi AP initial config
~~~
sw007#config
int gi1
switchport mode general
switchport general allowed vlan add 70,721,724,727,844,846,866,878,700 tagged
switchport general acceptable-frame-type all
switchport general pvid 721
switchport general allowed vlan add 721 untagged

sw007#show interfaces switchport gi1
Port : gi1
Port Mode : General
Gvrp Status : disabled
Ingress Filtering : enabled
Acceptable Frame Type : all
Ingress UnTagged VLAN ( NATIVE ) : 1
Trunking VLANs Enabled:

Port is member in:
 Vlan            Name              Egress rule
------- ----------------------- -----------------
    1                default       Untagged
   70                   BASE         Tagged
  721           OFFICE_ADMIN       Untagged
  724                 OFFICE         Tagged
  727                  GUEST         Tagged
  844                   ESXI         Tagged
  846                 GUEST2         Tagged
  866                CAMERAS         Tagged
  878               PRINTERS         Tagged
  700               INTERNAL         Tagged

Forbidden VLANs:
 Vlan            Name
------- -----------------------
~~~

## AP port when Unifi VLAN is in use
~~~
# This config is when the AP has been configured already for OFFICE_ADMIN 721 management VLAN
# in Unifi controller
sw007#config
int gi18
switchport mode general
switchport general allowed vlan add 70,721,724,727,844,846,866,878,700 tagged
switchport general acceptable-frame-type tagged-only
no switchport general pvid
end
~~~

## Reset Unifi AP
~~~
# Reset button or via SSH. If one wants to change Unifi controller, use "Forget" function in the controller.
* Enable Advanced Features in Unifi Controller and SSH to the AP and run "set-default"
* How to reset: https://help.ui.com/hc/en-us/articles/205143470-UniFi-How-to-Reset-Devices-to-Factory-Defaults
* How to enable SSH: https://help.ui.com/hc/en-us/articles/204709374
~~~

## Access ports
~~~
sw007#config
int gi19
switchport mode access
switchport access vlan 721

sw007#show interfaces switchport gi19
Port : gi19
Port Mode : Access
Gvrp Status : disabled
Ingress Filtering : enabled
Acceptable Frame Type : untagged-only
Ingress UnTagged VLAN ( NATIVE ) : 721
Trunking VLANs Enabled:

Port is member in:
 Vlan            Name              Egress rule
------- ----------------------- -----------------
  721            OFFICE_ADMIN       Untagged

Forbidden VLANs:
 Vlan            Name
------- -----------------------
~~~
