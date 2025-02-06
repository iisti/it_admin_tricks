# How to update a NIC driver on ESXi
* Source https://kb.vmware.com/s/article/2005205#OB

* The ESXi host went unresponsive when large amounts of data was being transferred. The culprit was probably old NIC driver.

* Information of ESXi host when 6.7 is installed
  ~~~
  [root@esxihost:/] vmware -vl
  VMware ESXi 6.7.0 build-14320388
  VMware ESXi 6.7.0 Update 3
  ~~~

* Checking ESXi NIC information
  ~~~
  [root@esxihost:/] esxcli network nic list
  Name    PCI Device    Driver  Admin Status  Link Status  Speed  Duplex  MAC Address         MTU  Description
  ------  ------------  ------  ------------  -----------  -----  ------  -----------------  ----  --------------------------------------------------
  vmnic0  0000:05:00.0  igb     Up            Up            1000  Full    00:25:90:1e:42:50  1500  Intel Corporation 82576 Gigabit Network Connection
  vmnic1  0000:05:00.1  igb     Up            Down             0  Half    00:25:90:1e:42:51  1500  Intel Corporation 82576 Gigabit Network Connection


  [root@esxihost:/] esxcli network nic get -n vmnic0
     Advertised Auto Negotiation: true
     Advertised Link Modes: 10BaseT/Half, 10BaseT/Full, 100BaseT/Half, 100BaseT/Full, 1000BaseT/Full
     Auto Negotiation: true
     Cable Type: Twisted Pair
     Current Message Level: 7
     Driver Info:
           Bus Info: 0000:05:00.0
           Driver: igb
           Firmware Version: 1.2.3
           Version: 5.0.5.1
     Link Detected: true
     Link Status: Up
     Name: vmnic0
     PHYAddress: 1
     Pause Autonegotiate: true
     Pause RX: false
     Pause TX: false
     Supported Ports: TP
     Supports Auto Negotiation: true
     Supports Pause: true
     Supports Wakeon: true
     Transceiver: internal
     Virtual Address: 00:50:56:50:72:8f
     Wakeon: MagicPacket(tm)

  [root@esxihost:/] vmkchdev -l | grep vmnic
  0000:05:00.0 8086:10c9 15d9:10c9 vmkernel vmnic0
  0000:05:00.1 8086:10c9 15d9:10c9 vmkernel vmnic1
  ~~~

* Checked via VMware Compatibility Guide that there's update to the NIC
  * https://www.vmware.com/resources/compatibility/detail.php?deviceCategory=io&productid=5325&deviceCategory=io&details=1&keyword=82576&DID=10c9&page=1&display_interval=10&sortColumn=Partner&sortOrder=Asc

    ~~~
    The ESXi 5.5 driver package includes version 5.2.5 of the Intel igb driver
    File size: 1 MB
    File type: ZIP 

    Name:	igb-5.2.5-1682588.zip
    Release Date: 	2014-03-21
    Build Number: 	1682588
    The ESXi 5.5 driver package includes version 5.2.5 of the Intel igb driver
    The ESXi 5.5 driver package includes version 5.2.5 of the Intel igb driver, which enables support for products based on the Intel 82580, I210, I350, and I354 Gigabit Ethernet Controllers. For detailed information and ESX hardware compatibility, check the I/O Hardware Compatibility Guide Web application.
    MD5SUM:	4f6eb3f351967aa865814b0ef990858f
    SHA1SUM: 	88dc4b34162380e59b1e9340b71a70441d78cb93
    ~~~~

* Install the driver
  ~~~
  [root@esxihost:/] esxcli software vib install -d /tmp/igb-5.2.5-1682588.zip
   [MetadataDownloadError]
   Could not download from depot at zip:/tmp/igb-5.2.5-1682588.zip?index.xml, skipping (('zip:/tmp/igb-5.2.5-1682588.zip?index.xml', '', 'Error extracting index.xml from /tmp/igb-5.2.5-1682588.zip: "There is no item named \'index.xml\' in the archive"'))
          url = zip:/tmp/igb-5.2.5-1682588.zip?index.xml
   Please refer to the log file for more details.

  [root@esxihost:/] unzip igb-5.2.5-1682588.zip

  [root@esxihost:/] esxcli software vib install -d /tmp/igb-5.2.5-offline_bundle-1682588.zip
  Installation Result
     Message: The update completed successfully, but the system needs to be rebooted for the changes to be effective.
     Reboot Required: true
     VIBs Installed: Intel_bootbank_net-igb_5.2.5-1OEM.550.0.0.1331820
     VIBs Removed: VMW_bootbank_net-igb_5.0.5.1.1-5vmw.670.0.0.8169922
     VIBs Skipped:
  ~~~
* Reboot and check the current driver
  ~~~
  [root@esxihost:~] esxcli network nic get -n vmnic0
     Advertised Auto Negotiation: true
     Advertised Link Modes: 10BaseT/Half, 10BaseT/Full, 100BaseT/Half, 100BaseT/Full, 1000BaseT/Full
     Auto Negotiation: true
     Cable Type: Twisted Pair
     Current Message Level: 7
     Driver Info:
           Bus Info: 0000:05:00.0
           Driver: igb
           Firmware Version: 1.2.3
           Version: 5.2.5
     Link Detected: true
     Link Status: Up
     Name: vmnic0
     PHYAddress: 1
     Pause Autonegotiate: true
     Pause RX: false
     Pause TX: false
     Supported Ports: TP
     Supports Auto Negotiation: true
     Supports Pause: true
     Supports Wakeon: true
     Transceiver: internal
     Virtual Address: 00:50:56:5c:3f:1a
     Wakeon: MagicPacket(tm)
  ~~~
