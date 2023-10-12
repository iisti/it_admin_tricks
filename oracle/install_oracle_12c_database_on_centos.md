# How to install Oracle 12c database on CentOS
* This doc should applies to CentOS 7, but CentOS 8 shouldn't be too much different.

## VM configuration
* CentOS minimal
* 2 vCPU
* 8 GB mem
* 50 GB disk (set 10 to swap during CentOS installation)

## Basic package installation
* Basic packages for installation
~~~
sudo yum update -y; \
sudo yum install -y vim open-vm-tools tmux git wget curl unzip; \
sudo yum -y groupinstall "Base"; \
cd ; \
wget https://gist.githubusercontent.com/simonista/8703722/raw/d08f2b4dc10452b97d3ca15386e9eed457a53c61/.vimrc; \
sed -i 's/^set tabstop=2/set tabstop=4/' .vimrc; \
sed -i 's/^set shiftwidth=2/set shiftwidth=4/' .vimrc; \
sed -i 's/^set softtabstop=2/set softtabstop=4/' .vimrc; \
sudo cp ~/.vimrc /root/
~~~


* A Desktop Environment is required by Oracle Database installer
    * https://unix.stackexchange.com/questions/181503/how-to-install-desktop-environments-on-centos-7
    ~~~
    yum -y groupinstall X11; \
    yum install -y epel-release; \
    yum update; \
    yum groups install "Xfce" 

    echo "exec /usr/bin/xfce4-session" >> ~/.xinitrc
    # Works only via ESXi GUI
    startx
    ~~~

## Install and configure Oracle 12c
* Source 1: https://www.howtoforge.com/tutorial/how-to-install-oracle-database-12c-on-centos-7/
* Source 2: https://www.centlinux.com/2016/02/centos-7-oracle-database-12c-install.html
* Source 3: https://www.server-world.info/en/note?os=CentOS_7&p=oracle12c&f=4

* Put whatever hostname you want for the server into 127.0.0.1
    ~~~
    [root@dev-oradb ~]# cat /etc/hosts
    127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4 dev-oradb dev-oradb.mydomain.com  oradb.mydomain.com
    ::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
    ~~~
    
* Edit sysct.conf
    ~~~
    echo "Editing sysctl.conf"; \
    MEMTOTAL=$(free -b | sed -n '2p' | awk '{print $2}'); \
    SHMMAX=$(expr $MEMTOTAL / 2); \
    SHMMNI=4096; \
    PAGESIZE=$(getconf PAGE_SIZE); \
    sudo tee -a /etc/sysctl.conf <<EOF
    #
    # Added for Oracle database configuration
    fs.aio-max-nr = 1048576
    fs.file-max = 6815744
    kernel.shmall = $(expr \( $SHMMAX / $PAGESIZE \) \* \( $SHMMNI / 16 \))
    kernel.shmmax = $SHMMAX
    kernel.shmmni = $SHMMNI
    kernel.sem = 250 32000 100 128
    net.ipv4.ip_local_port_range = 9000 65500
    net.core.rmem_default = 262144
    net.core.rmem_max = 4194304
    net.core.wmem_default = 262144
    net.core.wmem_max = 1048586
    EOF
    echo "Running the commands below to display all kernel parameter and apply the new values."; \
    sysctl -p; \ 
    sysctl -a
    ~~~
* Configure limits for Oracle user
    ~~~
    echo "Configure limits for the oracle user. Specify the max number process and max number of open files descriptors."; \
    echo "Editing limits.conf file." ;\
    sudo tee -a /etc/security/limits.conf <<EOF
    #
    # Added for Oracle database configuration
    oracle soft nproc 2047
    oracle hard nproc 16384
    oracle soft nofile 1024
    oracle hard nofile 65536
    EOF
    ~~~
* Install required packages
~~~
echo "Install required packages"; \
echo "compat-libcap1-1.10 was added as Oracle db installer Prerequisite Check was complaining" ;\
yum install -y binutils \
    compat-libstdc++-33 \
    compat-libstdc++-33.i686 \
    gcc \
    gcc-c++ \
    glibc \
    glibc.i686 \
    glibc-devel \
    glibc-devel.i686 \
    ksh \
    libgcc \
    libgcc.i686 \
    libstdc++ \
    libstdc++.i686 \
    libstdc++-devel \
    libstdc++-devel.i686 \
    libaio \
    libaio.i686 \
    libaio-devel \
    libaio-devel.i686 \
    libXext \
    libXext.i686 \
    libXtst \
    libXtst.i686 \
    libX11 \
    libX11.i686 \
    libXau \
    libXau.i686 \
    libxcb \
    libxcb.i686 \
    libXi \
    libXi.i686 \
    make \
    sysstat \
    unixODBC \
    unixODBC-devel \
    zlib-devel \
    zlib-devel.i686 \
    compat-libcap1-1.10
~~~

* Create user groups and oracle user
    ~~~
    echo "Create user groups and oracle user"; \
    groupadd -g 1101 oinstall; \
    groupadd -g 1102 dba; \
    groupadd -g 1103 oper; \
    groupadd -g 1104 backupdba; \
    groupadd -g 1105 dgdba; \
    groupadd -g 1106 kmdba; \
    groupadd -g 1107 asmdba; \
    groupadd -g 1108 asmoper; \
    groupadd -g 1109 asmadmin; \
    useradd -u 1101 -g oinstall -G dba,oper oracle; \
    passwd oracle
    ~~~

* Add desktop environtment conf for oracle user
    ~~~
    echo "Add possibility for desktop env for user oracle"; \
    echo "exec /usr/bin/xfce4-session" >> /home/oracle/.xinitrc; \
    chown oracle:oinstall /home/oracle/.xinitrc
    ~~~

* Make SELinux permissive
    ~~~
    echo "Oracle 12c Database is not compatible with SELinux. Making SELinux permissive."; \
    sed -i 's/^SELINUX=.*/SELINUX=permissive/g' /etc/sysconfig/selinux; \
    setenforce permissive
    ~~~

* Configure firewall
    ~~~
    echo "Configure Linux Firewall to allow Oracle SQL Net Listener to accept service requests on its default port."; \
    echo "Check zones"; \
    firewall-cmd --get-active-zones; \
    echo "Add port, apply conf, and check conf"; \
    firewall-cmd --zone=public --add-port=1521/tcp --permanent; \
    firewall-cmd --reload; \
    firewall-cmd --zone=public --list-all
    ~~~

* Create directories
    ~~~
    echo "Create directories for the Oracle database"; \
    echo "chmod g+s makes the new files created in the subdirectories have same group as parent."; \
    mkdir -p /u01; \
    chown -R oracle:oinstall /u01; \
    chmod -R 775 /u01; \
    chmod g+s /u01
    ~~~
    
* Login with oracle and fetch oracle12c database installation files
    ~~~
    echo "# Login with user oracle"; \
    echo "# Create folders for installation files, fetch and unzip them"; \
    su - oracle
    cd ~ ; \
    mkdir -p oracle12c_database_installation_files/unzipped; \
    cd oracle12c_database_installation_files

    # copy the files

    unzip oracle_12c_personal_db_12.1.0.2.0_linux_x86-64_V46095-01_1of2.zip -d unzipped/; \
    unzip oracle_12c_personal_db_12.1.0.2.0_linux_x86-64_V46095-01_2of2.zip -d unzipped/
    ~~~

* Run the installer in GUI environment
    ~~~
    # Login into desktop env via ESXi as "oracle" and run:
    startx
    # In terminal run:
    ~/oracle12c_database_installation_files/unzipped/database/runInstaller
    ~~~

### Installation with GUI
   1. Configure Security Updates
      * Skip
   1. Installation Option: Install database software only
   1. Grid Installation Options: Single instance database installation
   2. Product Languages: English
   3. Database Edition: Enterprise Edition (6.4 GB)
   4. Installation Location
      ~~~
      Oracle base: '/u01/app/oracle'
      Software location: /u01/app/oracle/product/12.1.0/dbhome_1
      ~~~
   1. Create inventory
      ~~~
      Inventory Directory: /u01/app/orainventory
      orainventory Group Name: oinstall
      ~~~
   1. Operating System Groups
      ~~~
      Database Administrator (OSDBA) group:                     dba
      Database Operator (OSOPER) group (Optional):              oper
      Database Backup and Recovery (OSBACKUPDBA) group:         dba
      Database Guard administrative (OSDGDBA) gropu:            dba
      Encryption Key Management administrative (OSKMDBA) group: dba
      ~~~
   1. Install product
      * Run scripts as root

## Configurations after
* Set environment variables
   ~~~
   sudo tee /etc/profile.d/oracle_db_env_variables.sh <<'EOF'
   # Added for Oracle database administration
   ORACLE_SID=orcl; export ORACLE_SID
   ORACLE_BASE=/u01/app/oracle; export ORACLE_BASE
   ORACLE_HOME=/u01/app/oracle/product/12.1.0/dbhome_1; export ORACLE_HOME
   PATH=$PATH:$ORACLE_HOME/bin; export PATH
   CLASSPATH=$ORACLE_HOME/jlib:$ORACLE_HOME/rdbms/jlib; export CLASSPATH
   EOF
   ~~~

* Create listener by running command below in GUI
~~~
/u01/app/oracle/product/12.1.0/dbhome_1/bin/netca
~~~

* Create database by running command below in GUI
~~~
/u01/app/oracle/product/12.1.0/dbhome_1/bin/dcba
~~~
