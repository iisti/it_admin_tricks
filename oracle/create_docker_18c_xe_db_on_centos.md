# Create an Oracle 18c XE database on CentOS Docker container

## Virtual machine information
* CentOS 8

## Install Docker

* Source: https://docs.docker.com/engine/install/centos/

      sudo yum update
      sudo yum install -y yum-utils
      sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
      sudo yum install docker-ce docker-ce-cli containerd.io
      sudo systemctl start docker
      sudo docker run hello-world
      
## Create Oracle Docker Image
* Source: https://blogs.oracle.com/oraclemagazine/deliver-oracle-database-18c-express-edition-in-containers
* Go to section **Running Oracle Database in Docker**

      # You could create user "Oracle" for Docker
      sudo yum install -y git wget tmux
      git clone https://github.com/oracle/docker-images.git
      cd docker-images/OracleDatabase/SingleInstance/dockerfiles/
      ./buildDockerImage.sh -v 18.4.0 -x
      sudo ./buildDockerImage.sh -v 18.4.0 -x
      sudo usermod -aG docker <your user or Oracle user>
      # You need to create new session (or switch to user Oracle), so that you can use docker commands without sudo.
      docker images

## Install SQL*Plus
* Source: https://documentacoes.wordpress.com/2018/11/03/install-oracle-sqlplus-on-centos-7/

      sudo yum install wget vim tmux
      wget https://download.oracle.com/otn_software/linux/instantclient/199000/oracle-instantclient19.9-basic-19.9.0.0.0-1.x86_64.rpm
      sudo yum localinstall oracle-instantclient19.9-basic-19.9.0.0.0-1.x86_64.rpm
      
      wget https://download.oracle.com/otn_software/linux/instantclient/199000/oracle-instantclient19.9-sqlplus-19.9.0.0.0-1.x86_64.rpm
      sudo yum localinstall oracle-instantclient19.9-sqlplus-19.9.0.0.0-1.x86_64.rpm 
      
      ls -la /usr/lib/oracle/19.9/client64/lib/
      echo /usr/lib/oracle/19.9/client64/lib | sudo tee -a /etc/ld.so.conf.d/oracle.conf 
      sudo vim /etc/ld.so.conf.d/oracle-instantclient.conf 
      sudo ldconfig
      sudo vim /etc/profile.d/oracle.sh
      # Put this content to oracle.sh
      export LD_LIBRARY_PATH=/usr/lib/oracle/19.9/client64/lib:$LD_LIBRARY_PATH
      export PATH=/usr/lib/oracle/19.9/client64/bin:$PATH

      source /etc/profile.d/oracle.sh 

      # Check if sqlplus is found
      which sqlplus
      
      
* ERROR when trying to connect

      sqlplus localhost:51521/XE
      
      SQL*Plus: Release 19.0.0.0.0 - Production on Tue Dec 1 12:02:41 2020
      Version 19.9.0.0.0
      
      Copyright (c) 1982, 2020, Oracle.  All rights reserved.
      
      ERROR:
      ORA-12162: TNS:net service name is incorrectly specified
      
  * Fix
    * Source: http://www.dba-oracle.com/t_ora_12162_tns_net_service_name.htm
    * Source: https://www.poftut.com/oracle-ora-12162-tnsnet-service-name-is-incorrectly-specified-error-and-solution/
      
          ORACLE_HOME="~/docker/myxedb"; export ORACLE_HOME
          ORACLE_SID="XE"; export ORACLE_SID

## Start Docker and the XE database container
* Create folders for saving Oracle data

      mkdir -p ~/docker/myxedb/oradata
      chmod 777 ~/docker/myxedb/oradata
      
* Run XE container
      
      docker run --name myxedb \
      -d \
      -p 51521:1521 \
      -p 55500:5500 \
      -e ORACLE_PWD=SECUREPASS2 \
      -e ORACLE_CHARACTERSET=AL32UTF8 \
      -v ~/docker/myxedb/oradata:/opt/oracle/oradata \
      -v ~/docker/myxedb/scripts/setup:/opt/oracle/scripts/setup \
      -v ~/docker/myxedb/scripts/startup:/opt/oracle/scripts/startup \
      oracle/database:18.4.0-xe
      
* Check logs when container has started properly.
  * Note from the logs below that the user to login is **SYSTEM**.

      ~~~    
      docker logs -f myxedb


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
