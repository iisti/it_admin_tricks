# Create an Oracle 18c XE database on CentOS Docker container

## Virtual machine information
* CentOS 7 and 8

## Basic packages
* Update and install basic packages
    ~~~
    sudo yum update -y; \
    sudo yum install -y git wget tmux vim
    ~~~

## Create swap file
* [Create swap file](../linux/create_swap_file.md)

## Install Docker
* [Docker Install](../docker/docker_install.md)

      
## Create Oracle Docker Image
* Source: https://blogs.oracle.com/oraclemagazine/deliver-oracle-database-18c-express-edition-in-containers
* Section **Running Oracle Database in Docker** from the source above.
    ~~~
    # Creating an "Oracle" user for Docker is optional
    sudo useradd oracle
    sudo usermod -aG docker oracle
    sudo passwd oracle

    build_folder="/opt/oracle_xe18c"
    sudo mkdir "$build_folder"
    sudo chown oracle:oracle "$build_folder"
    sudo chmod g+s "$build_folder"

    su - oracle
    cd "$build_folder"
    git clone https://github.com/oracle/docker-images.git
    cd docker-images/OracleDatabase/SingleInstance/dockerfiles/
    ./buildContainerImage.sh -v 18.4.0 -x

    # Output of the end
      Oracle Database container image for 'xe' version 18.4.0 is ready to be extended:
        --> oracle/database:18.4.0-xe
      Build completed in 1164 seconds.
    ~~~

    * List docker images
        ~~~
        # You need to create new session (or switch to user Oracle), so that you can use docker commands without sudo.
        docker images
        ~~~
## Install SQL*Plus
* Source: https://documentacoes.wordpress.com/2018/11/03/install-oracle-sqlplus-on-centos-7/
    ~~~
    wget https://download.oracle.com/otn_software/linux/instantclient/191000/oracle-instantclient19.10-basic-19.10.0.0.0-1.x86_64.rpm
    sudo yum localinstall oracle-instantclient19.10-basic-19.10.0.0.0-1.x86_64.rpm

    wget https://download.oracle.com/otn_software/linux/instantclient/191000/oracle-instantclient19.10-sqlplus-19.10.0.0.0-1.x86_64.rpm
    sudo yum localinstall oracle-instantclient19.10-sqlplus-19.10.0.0.0-1.x86_64.rpm 

    # Check the installation path
    ls -la /usr/lib/oracle/19.10/client64/lib/
    # Add paths to  system library
    echo /usr/lib/oracle/19.10/client64/lib | sudo tee -a /etc/ld.so.conf.d/oracle.conf 
    #sudo vim /etc/ld.so.conf.d/oracle-instantclient.conf 
    sudo ldconfig

    # Creating an oracle.sh for appending environment variables into profiles
    sudo tee -a /etc/profile.d/oracle.sh <<'EOF'
    export LD_LIBRARY_PATH=/usr/lib/oracle/19.10/client64/lib:$LD_LIBRARY_PATH
    export PATH=/usr/lib/oracle/19.10/client64/bin:$PATH
    ORACLE_HOME="/opt/docker_xedb18c"; export ORACLE_HOME
    ORACLE_SID="XE"; export ORACLE_SID
    EOF

    source /etc/profile.d/oracle.sh 

    # Check if sqlplus is found
    which sqlplus
    ~~~
      
      
* TNS Error when trying to connect
    ~~~
    sqlplus localhost:51521/XE

    SQL*Plus: Release 19.0.0.0.0 - Production on Tue Dec 1 12:02:41 2020
    Version 19.10.0.0.0

    Copyright (c) 1982, 2020, Oracle.  All rights reserved.

    ERROR:
    ORA-12162: TNS:net service name is incorrectly specified
    ~~~     
    * Fix
        * Source: http://www.dba-oracle.com/t_ora_12162_tns_net_service_name.htm
        * Source: https://www.poftut.com/oracle-ora-12162-tnsnet-service-name-is-incorrectly-specified-error-and-solution/
        ~~~
        # This is done already in the above profile conf, but left here just, so it's not needed to be researched again.
        ORACLE_HOME="/opt/docker_xedb18c"; export ORACLE_HOME
        ORACLE_SID="XE"; export ORACLE_SID
        ~~~

## Deploy Docker 18c XE database container
* Create folders for saving Oracle data
    ~~~
    oradata_folder="/opt/docker_xedb18c/oradata"
    mkdir -p "$oradata_folder"
    chmod 777 "$oradata_folder"
    chown oracle:oracle "$oradata_folder"
    
    scripts_folder="/opt/docker_xedb18c/scripts"
    mkdir -p "$scripts_folder"
    chmod 777 "$scripts_folder"
    chown oracle:oracle "$scripts_folder"
    ~~~
* Run XE 18c container
    ~~~ 
    docker run --name xedb18c \
    -d \
    -p 51521:1521 \
    -p 55500:5500 \
    -e ORACLE_PWD=SECUREPASS2 \
    -e ORACLE_CHARACTERSET=AL32UTF8 \
    -v /opt/docker_xedb18c/oradata:/opt/oracle/oradata \
    -v /opt/docker_xedb18c/scripts/setup:/opt/oracle/scripts/setup \
    -v /opt/docker_xedb18c/scripts/startup:/opt/oracle/scripts/startup \
    oracle/database:18.4.0-xe
    ~~~
* Check logs when container has started properly.
  * Note from the logs below that the user to login is **SYSTEM**.

      ~~~    
      docker logs -f xedb18c


      #### Snip from docker logs
      ORACLE PASSWORD FOR SYS AND SYSTEM: SECUREPASS2
      Specify a password to be used for database accounts.
      Oracle recommends that the password entered should be at least 8 characters in length,
      contain at least 1 uppercase character, 1 lower case character and 1 digit [0-9].
      Note that the same password will be used for SYS, SYSTEM and PDBADMIN accounts:
      Confirm the password:
      Configuring Oracle Listener.
      Listener configuration succeeded.
      Configuring Oracle Database XE.
      Enter SYS user password: 
      *************
      Enter SYSTEM user password: 
      ************
      Enter PDBADMIN User Password: 
      ***********
      .
      .
      .
      Completed: ALTER PLUGGABLE DATABASE XEPDB1 SAVE STATE
      ####
      ~~~
      
* Check that the database can be connected.

      echo 'SELECT SYSDATE FROM DUAL;' | sqlplus -S system/SECUREPASS2@localhost:51521/XE

      SYSDATE
      ---------
      04-DEC-20

* It was tested that connection worked also with Win 10 and Oracle SQL Developer 20.2.0.175 with the settings below. Click green plus for new connection
      
      Database Type: Oracle
      User Info
        Authentication Type: Default
        Username: system
          Role: default
        Password: SECUREPASS2
      Connection Type: Basic
        Hostname: IP of CentOS machine
        Port: 51521
        SID: XE

## Deploy Docker 11gR2 XE database container
* Create 11gR2 docker image
    ~~~
    mkdir /opt/oracle_xe11c
    cd /opt/oracle_xe11c
    git clone https://github.com/oracle/docker-images.git
    cd docker-images/OracleDatabase/SingleInstance/dockerfiles/
    # Download oracle-xe-11.2.0-1.0.x86_64.rpm.zip into docker-images/OracleDatabase/SingleInstance/dockerfiles/11.2.0.2
    # https://www.oracle.com/webapps/redirect/signon?nexturl=https://download.oracle.com/otn/linux/oracle11g/xe/oracle-xe-11.2.0-1.0.x86_64.rpm.zip
    
    # Build the new container
    ./buildContainerImage.sh -v 11.2.0.2 -x
    ~~~

* Create folders for saving Oracle data
    ~~~
    mkdir -p ~/docker/xedb11gr2/oradata
    chmod 777 ~/docker/xedb11gr2/oradata
    ~~~

* Create Dockerfile, cat Dockerfile
    ~~~
    FROM oracle/database:11.2.0.2-xe
    RUN chown -R oracle:dba /u01/app/oracle/oradata
    ~~~

* Run XE 11g R2 container
    ~~~
    docker run --name xedb11gr2 \
    --shm-size=1g \
    -p 1521:1521 \
    -p 8081:8080 \
    -e ORACLE_PWD=12345 \
    -e ORACLE_CHARACTERSET=AL32UTF8 \
    -v ~/docker/xedb11gr2/oradata:/opt/oracle/oradata \
    oracle/database:11.2.0.2-xe
    ~~~
    
    * There will be probably errors, the creation of Dockerfile should have fixed this, but there's a manual solution in below.
    ~~~
    SQL> Disconnected from Oracle Database 11g Express Edition Release 11.2.0.2.0 - 64bit Production
    mv: failed to access '/u01/app/oracle/oradata/dbconfig/XE/': Permission denied
    mv: failed to access '/u01/app/oracle/oradata/dbconfig/XE/': Permission denied
    mv: failed to access '/u01/app/oracle/oradata/dbconfig/XE/': Permission denied
    mv: failed to access '/u01/app/oracle/oradata/dbconfig/XE/': Permission denied
    #####################################
    ########### E R R O R ###############
    DATABASE SETUP WAS NOT SUCCESSFUL!
    Please check output for further info!
    ~~~
    
    * Fix file permissions
        ~~~ 
        docker ps 
        docker exec -it -u 0 <container_ID> bash

        bash-4.2# ls -la /u01/app/oracle/
        total 20
        drwxr-xr-x. 1 oracle     dba         108 Apr  8 19:45 .
        drwxr-xr-x. 1 root       root         20 Apr  8 18:40 ..
        drwxr-x---. 4 oracle     dba          35 Apr  8 19:45 admin
        -rwxrwxr-x. 1 root       root        999 Nov 30 14:40 checkDBStatus.sh
        drwxrwxr-x. 4 oracle     dba          34 Apr  8 19:45 diag
        drwxr-x---. 3 oracle     dba          16 Apr  8 19:45 fast_recovery_area
        drwxr-x---. 4 1519949849 1519949849   32 Apr  8 19:45 oradata
        drwxr-xr-x. 3 oracle     dba          18 Apr  8 19:45 oradiag_oracle
        drwxr-xr-x. 1 oracle     dba          20 Apr  8 18:40 product
        -rwxrwxr--. 1 root       root       6901 Nov 30 14:40 runOracle.sh
        drwxr-xr-x. 4 oracle     dba          34 Apr  8 18:40 scripts
        -rwxrwxr--. 1 root       root        193 Nov 30 14:40 setPassword.sh
        -rw-rw-r--. 1 root       root       2921 Apr  8 19:45 xe.rsp

        chown -R oracle:dba /u01/app/oracle/oradata

        bash-4.2# ls -la /u01/app/oracle/
        total 20
        drwxr-xr-x. 1 oracle dba   108 Apr  8 19:45 .
        drwxr-xr-x. 1 root   root   20 Apr  8 18:40 ..
        drwxr-x---. 4 oracle dba    35 Apr  8 19:45 admin
        -rwxrwxr-x. 1 root   root  999 Nov 30 14:40 checkDBStatus.sh
        drwxrwxr-x. 4 oracle dba    34 Apr  8 19:45 diag
        drwxr-x---. 3 oracle dba    16 Apr  8 19:45 fast_recovery_area
        drwxr-x---. 4 oracle dba    32 Apr  8 19:45 oradata
        drwxr-xr-x. 3 oracle dba    18 Apr  8 19:45 oradiag_oracle
        drwxr-xr-x. 1 oracle dba    20 Apr  8 18:40 product
        -rwxrwxr--. 1 root   root 6901 Nov 30 14:40 runOracle.sh
        drwxr-xr-x. 4 oracle dba    34 Apr  8 18:40 scripts
        -rwxrwxr--. 1 root   root  193 Nov 30 14:40 setPassword.sh
        -rw-rw-r--. 1 root   root 2921 Apr  8 19:45 xe.rsp
        ~~~

* Start the container
    ~~~
    docker container start xedb11gr2
    docker ps
    docker logs --follow <container_ID>
        #########################
        DATABASE IS READY TO USE!
        #########################
    ~~~
