
### Enable Hyper-V
* https://docs.microsoft.com/en-us/virtualization/hyper-v-on-windows/quick-start/enable-hyper-v

### StarWind V2V Converter
Download and install StarWind V2V Converter
    * https://www.starwindsoftware.com/starwind-v2v-converter#download

### Prerequisites
* Source https://www.starwindsoftware.com/v2v-help/UsingStarWindV2VConverterwithAmazonWebServices.html

* StarWind V2V Converter allows for converting a virtual machine running on-premises or its virtual disk image to an Amazon Web Services virtual machine and vice versa. Conversion is done by creating a new virtual machine in the destination location that has the same parameters (i.e., the number of vCPUs, amount of RAM, etc.) as the original virtual machine.
* Before converting a virtual machine or an image file, check whether the following prerequisites are met:
  * Network adapters are enabled on system boot;
  * Network adapters have IP addresses assigned over DHCP;
  * RDP or SSH are enabled;
  * Firewall is set to allow for remote connections over RDP or SSH;
  * The VM that is to be converted is powered off.

* Before converting a virtual machine, virtual machine disk, or a local file to Amazon Web Services, StarWind V2V Converter users are to
  * create an Amazon Web Services Account;
  * create a key pair for each region where the virtual machines are running;
  * create firewall rules at security group;
  * generate an access key ID and secret access key.
