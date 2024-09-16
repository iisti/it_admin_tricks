# How to use Application Migration Service to migrate live servers to AWS

## Migrate VM from GCP to AWS

### Source VM Debian 9
* Destination Zone is eu-west-1

#### Prepare the source
1. Update/upgrade packages
1. Create local user with sudo permissions!
    * If you forgot this step before migration, sometimes you're still able to login via serial console the VM with Google user.
    ~~~
    sudo adduser sysop
    sudo visudo
    ~~~
    
#### Install AWS Replication Agent
*  https://docs.aws.amazon.com/mgn/latest/ug/linux-agent.html
~~~
wget -O ./aws-replication-installer-init.py https://aws-application-migration-service-eu-west-1.s3.amazonaws.com/latest/linux/aws-replication-installer-init.py 
sudo python3 aws-replication-installer-init.py
~~~

### Fix issues after migration
#### Cannot login at all
* Enable serial console
  * https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/connect-to-serial-console.html
  * Set machine type to one which supports serial console, for example T3a.xlarge
* When starting the instance there's error:
    ~~~
    Failed to start the instance i-0b49bf20449ed30d2
    Enhanced networking with the Elastic Network Adapter (ENA) is required for the 't3a.xlarge' instance type. Ensure that your instance 'i-03dadbbc726fb76b5' is enabled for ENA.
    ~~~
    * Fix
      ~~~ 
      aws ec2 --profile=PROFILE modify-instance-attribute --instance-id i-0a8d8b5d1b8b9xxxx --ena-support
      aws ec2 --profile=PROFILE describe-instances --instance-id i-0a8d8b5d1b8b9xxxx --query "Reservations[].Instances[].EnaSupport"
          [
          true
          ]
      ~~~
* Connect with serial console.
* Check if amazon-ssm-agent is installed.
  ~~~
  sudo apt list --installed | grep amazon
  sudo dpkg-query -l | grep amazon
* Install amazon-ssm-agent
  ~~~ 
  wget https://s3.eu-west-1.amazonaws.com/amazon-ssm-eu-west-1/latest/debian_amd64/amazon-ssm-agent.deb
  sudo dpkg -i amazon-ssm-agent.deb
  ~~~
* Remove Google packages
  * Check which ones are installed.
    ~~~
    sysop@ip-172-31-15-40:~$ sudo apt list --installed | grep google

    WARNING: apt does not have a stable CLI interface. Use with caution in scripts.

    google-cloud-packages-archive-keyring/google-cloud-packages-archive-keyring-stretch,now 1.2-411592600 all [installed]
    google-cloud-sdk/cloud-sdk-stretch,now 365.0.1-0 all [installed]
    google-compute-engine/now 1:20190916.00-g2 all [installed,upgradable to: 1:20210916.00-g1]
    google-compute-engine-oslogin/google-compute-engine-stretch-stable,now 1:20210907.00-g1+deb9 amd64 [installed,automatic]
    google-osconfig-agent/google-compute-engine-stretch-stable,now 1:20211102.00-g1 amd64 [installed]
    python-google-compute-engine/google-compute-engine-stretch-stable,now 1:20191210.00-g1 all [installed]
    python3-google-compute-engine/google-compute-engine-stretch-stable,now 1:20191210.00-g1 all [installed]
    ~~~ 

* Remove package infos
  * There was errors when trying to remove/install google-packages when old infos were in place, so they were moved before anything was done.
  * Found Google info files
    ~~~
    cd /var/lib/dpkg/info/
    ls -la | grep google
        -rwxr-xr-x 1 root root       0 Jan  1  2000 google-cloud-packages-archive-keyring.conffiles
        -rw-r--r-- 1 root root     105 Nov 26 16:32 google-cloud-packages-archive-keyring.list
        -rw-r--r-- 1 root root      98 Jan  1  2000 google-cloud-packages-archive-keyring.md5sums
        -rw-r--r-- 1 root root 2305408 Nov 26 16:33 google-cloud-sdk.list
        -rw-r--r-- 1 root root 2936644 Nov 19 23:12 google-cloud-sdk.md5sums
        -rwxr-xr-x 1 root root     276 Nov 19 23:12 google-cloud-sdk.postinst
        -rwxr-xr-x 1 root root     468 Nov 19 23:12 google-cloud-sdk.prerm
        -rw-r--r-- 1 root root      38 Nov 19 22:30 google-cloud-sdk.triggers
        -rw-r--r-- 1 root root     177 Sep 16  2019 google-compute-engine.conffiles
        -rw-r--r-- 1 root root    1175 Dec 10  2019 google-compute-engine.list
        -rw-r--r-- 1 root root    1114 Sep 16  2019 google-compute-engine.md5sums
        -rw-r--r-- 1 root root    1137 Nov 12 14:17 google-compute-engine-oslogin.list
        -rw-r--r-- 1 root root    1205 Sep  7 18:26 google-compute-engine-oslogin.md5sums
        -rwxr-xr-x 1 root root    1004 Sep  7 18:26 google-compute-engine-oslogin.postinst
        -rwxr-xr-x 1 root root     623 Sep  7 18:26 google-compute-engine-oslogin.postrm
        -rwxr-xr-x 1 root root     195 Sep  7 18:26 google-compute-engine-oslogin.prerm
        -rw-r--r-- 1 root root     100 Sep  7 18:26 google-compute-engine-oslogin.shlibs
        -rw-r--r-- 1 root root      60 Sep  7 18:26 google-compute-engine-oslogin.triggers
        -rwxr-xr-x 1 root root    5698 Sep 16  2019 google-compute-engine.postinst
        -rwxr-xr-x 1 root root     935 Sep 16  2019 google-compute-engine.postrm
        -rwxr-xr-x 1 root root    1119 Sep 16  2019 google-compute-engine.preinst
        -rwxr-xr-x 1 root root     963 Sep 16  2019 google-compute-engine.prerm
        -rw-r--r-- 1 root root    6010 Nov 12 14:17 google-osconfig-agent.list
        -rw-r--r-- 1 root root    3252 Nov  2 23:00 google-osconfig-agent.md5sums
        -rwxr-xr-x 1 root root    1317 Nov  2 23:00 google-osconfig-agent.postinst
        -rwxr-xr-x 1 root root     274 Nov  2 23:00 google-osconfig-agent.postrm
        -rwxr-xr-x 1 root root     236 Nov  2 23:00 google-osconfig-agent.prerm
        -rw-r--r-- 1 root root    7733 Dec 10  2019 python3-google-compute-engine.list
        -rw-r--r-- 1 root root    8314 Dec 10  2019 python3-google-compute-engine.md5sums
        -rwxr-xr-x 1 root root     181 Dec 10  2019 python3-google-compute-engine.postinst
        -rwxr-xr-x 1 root root     433 Dec 10  2019 python3-google-compute-engine.prerm
        -rw-r--r-- 1 root root    7740 Dec 10  2019 python-google-compute-engine.list
        -rw-r--r-- 1 root root    8114 Dec 10  2019 python-google-compute-engine.md5sums
        -rwxr-xr-x 1 root root     178 Dec 10  2019 python-google-compute-engine.postinst
        -rwxr-xr-x 1 root root     293 Dec 10  2019 python-google-compute-engine.prerm
    ~~~
  *  Move the info files
    ~~~
    mkidr ~/google_dpkg_bak
    sudo mv google-compute-engine-oslogin.* ~/google_dpkg_bak/
    sudo mv python3-google-compute-engine.* ~/google_dpkg_bak/
    ~~~
  * Reconfigure/fix dpkg
    ~~~
    sudo dpkg --configure -a
    ~~~ 
  * Install the package and remove, so there will clean removal
    ~~~
    sudo apt install google-compute-engine-oslogin
    sudo apt remove google-compute-engine-oslogin
    sudo apt install google-compute-engine-oslogin
    sudo apt remove google-compute-engine-oslogin
    ~~~
  * Remove also the other google packages

* Comment out Google packages/configurations from these authentication conf files
  ~~~
  /etc/ssh/sshd_config
  /etc/pam.d/sshd
  /etc/pam.d/su
  ~~~
* Reboot
* SSH should work with the local user
