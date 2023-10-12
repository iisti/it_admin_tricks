# SFTP server with jail directories and Apache2
* SFTP users can use SFTP, but no SSH.
* Files can be downloaded via browser.
* CentOS 7 was used as a server.
* Good tips: https://wiki.archlinux.org/title/SCP_and_SFTP

## No SSH for SFTP users
* Create sftpusers group
    * If you are mounting NFS share as file storage, one can also determine GIDs when creating groups. `-g <GID>` can be ignored if using internal disk.
    * `sftpusers` is for determining permissions for files/directories.
    * `sftp_only` is for restricting access only for SFTP.
    * One can have special user with SSH access and right file permissions when those 2 groups are separated.
       ~~~
       sudo groupadd -g 1100 sftpusers
       sudo groupadd -g 1101 sftp_only
       ~~~

* Append into /etc/ssh/sshd_config
    ~~~
    # Enforces that "sftp_only" group can only use SFTP and no SSH
    # Denies entry even when /bin/nologin is changed to  /bin/bash
    Match Group sftp_only
        X11Forwarding no
        AllowTcpForwarding no
        ChrootDirectory %h
        ForceCommand internal-sftp
        AllowAgentForwarding no
        AllowGroups sftp_only
    ~~~
  * Add also that exclusive groups can use SSH
    ~~~
    AllowGroups wheel sysop ssh_users
    ~~~
    
## File structure configuration
* Create file structure
    ~~~ 
    mkdir /opt/sftp_storage
    ~~~

## A script for adding a user
* add_sftp_user.bash
    ~~~
    #!/bin/bash

    # Changes:

    # Checking that the script has been executed as a superuser
    if [ "$USER" != "root" ]; then
        tput setaf 3; # Yellow text
        echo "This script should be executed as superuser - use sudo!" 2>&1
        echo "Exiting..." 2>&1
        tput sgr0; # Default text color
        exit
    fi

    echo -n "Give username: "
    read username

    path_storage="/opt/sftp_storage/"

    echo "Creating user, homedir, add to group ftp, set shell /bin/nologin ..."
    useradd -d "$path_storage""$username" -g sftpusers -s /bin/nologin $username
    usermod -a -G sftp_only "$username"
    chown -R root:root "$path_storage""$username"
    chmod -R 755 "$path_storage""$username"
    mkdir "$path_storage""$username"/files
    chown $username. "$path_storage""$username"/files

    # Create password for the user
    passwd $username

    echo "Generating HTTP password..."
    htpasswd -c "$path_storage""$username"/.htpasswd $username
    sudo tee "$path_storage""$username"/.htaccess <<EOF
    AuthType Basic
    AuthName "Restricted Files"
    AuthUserFile $path_storage$username/.htpasswd
    require valid-user
    EOF

    echo "SFTP user has been created. Check that access works."
    ~~~
    * The script is using htpasswd for authenticating/authorizing, but one could use also local users/groups with Apache/httpd modules.
         * See https://serverfault.com/a/1030083/323362

## httpd / apache2 configuration
* /etc/httpd/sites-enabled/sftp.domain.com.conf
* This could probably use some cleanup.
    ~~~
    <VirtualHost *:80>
        ServerAdmin mail@domain.com
        ServerName sftp.domain.com
        DocumentRoot /opt/sftp_storage

        <Directory /opt/sftp_storage>
            Options Indexes FollowSymLinks MultiViews
            # Show full file names
            <IfModule mod_autoindex.c>
                IndexOptions NameWidth=*
            </ifModule>
            AllowOverride All
            Order allow,deny
            Allow from all

            # For some reason ä and ö didn't show up correctly without this, even though UTF-8 is default for httpd
            # Source: https://stackoverflow.com/questions/913869/how-to-change-the-default-encoding-to-utf-8-for-apache
            IndexOptions +Charset=UTF-8
        </Directory>

        # Possible values include: debug, info, notice, warn, error, crit,
        # alert, emerg.
        LogLevel warn

        ErrorLog /var/log/httpd/sftp_error.log
        CustomLog /var/log/httpd/sftp_access.log combined
    </VirtualHost>
    ~~~

## Configure NFS storage (optional)
* With NFS permission inheritance doesn't work the same way as local disks/files, so the default ACL settings must be set on NFS server.
* For clarity create `sftpusers` group in NFS server with same GID as in the SFTP server.

### Mounting NFS, so Apache can access the files
* If one doesn't mount the NFS with correct context, Apache cannot access it and in the logs could be shown:
   ~~~
   [Tue May 11 15:45:21.572168 2021] [authz_core:error] [pid 20957] [client 192.168.3.20:58866] AH01630: client denied by server configuration: /opt/freenas_sftp_files 
   ~~~
* Set in /etc/fstab
   ~~~
   # Storage for sftp files
   freenas.domain.com:/mnt/pool01/sftp_files /opt/freenas_sftp_files nfs4 context="system_u:object_r:httpd_sys_rw_content_t:s0" 0 0
   ~~~
* semanage is a utility for managing SELinux contexts
    ~~~
    yum provides /usr/sbin/semanage
    yum install policycoreutils-python
    ~~~

### FreeNAS/TrueNAS (FreeBSD) ACL
* man setfacl https://www.freebsd.org/cgi/man.cgi?query=setfacl&sektion=1
* Changing ACL for sftp files "root" folder, so that owner and group have rwx automatically.
* Original file permissions on FreeNAS NFS server
    ~~~
    root@freenas[/mnt/pool01]# getfacl sftp_files
    # file: sftp_files
    # owner: root
    # group: wheel
                owner@:rwxp--aARWcCos:-------:allow
                group@:r-x---a-R-c--s:-------:allow
             user:root:rwxpDdaARWc--s:fd----I:allow
             everyone@:r-x---a-R-c--s:-------:allow
    ~~~

* Set rwx for user and group and that the permissions are inheritable
    ~~~
    setfacl -m owner@:rwxpaARWcCos:fd:allow sftp_files
    setfacl -m group@:rwxaRcs:fdiI:allow sftp_files
    ~~~

* ACL after changes
    ~~~
    root@freenas[/mnt/pool01]# getfacl sftp_files
    # file: sftp_files
    # owner: root
    # group: wheel
                owner@:rwxp--aARWcCos:fd-----:allow
                group@:rwxp--a-R-c--s:fdi---I:allow
             user:root:rwxpDdaARWc--s:fd----I:allow
             everyone@:r-x---a-R-c--s:-------:allow
    ~~~

* If there are already files/directories in the sftp files root directory, one can change the ACL recursively with commands below.
    * Notice that argument `-R` doesn't work with FreeNAS and many other FreeBSD based systems.
        * Set owner's permissions rwx and inheritable for folders
            ~~~ 
            find /mnt/pool01/sftp_files/ -type d -exec setfacl -m owner@:rwxpaARWcCos:fdI:allow {} \;
            ~~~
        * Set group's permissions rwx and inheritable for folders
            ~~~
            find /mnt/pool01/sftp_files/ -type d -exec setfacl -m group@:rwxpaRcs:fdiI:allow {} \;
            ~~~

## Some handy commands for changing permissions/etc in bulk
* These should be run on the SFTP server
    ~~~
    # $u == username

    # Run to change the home directory
    cd /opt/freenas_sftp_files
    for u in *; do if [ -d "$u" ]; then sudo usermod -d /opt/freenas_sftp_files/"$u" "$u"; fi; done

    # Run to replace .htpasswd paths
    cd /opt/freenas_sftp_files
    for u in *; do if [ -d "$u" ]; then  sed -i 's/storage/freenas_sftp_files/g' "$u"/.htaccess; fi; done

    # Run to change primary group
    cd /opt/freenas_sftp_files
    for u in *; do if [ -d "$u" ]; then sudo usermod -g sftp_users "$u"; fi; done

    # Run to add into another group
    cd /opt/freenas_sftp_files
    for u in *; do if [ -d "$u" ]; then sudo usermod -a -G sftp_only "$u"; fi; done

    # Change ownerships of all files and folders under username/files
    cd /opt/freenas_sftp_files
    for u in *; do if [ -d "$u" ]; then sudo chown -R "$u":sftp_users "$u"/files; fi; done
    ~~~
