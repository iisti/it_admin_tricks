# How to install, configure and use PrivateBin

* PrivateBin is a service for sending sensitive data over browser links

## Install/Upgrade on Linux
  ~~~
  # Variables
  pbin_folder="/var/www/privatebin.domain.com"

  download_url_latest="https://api.github.com/repos/PrivateBin/PrivateBin/releases/latest"
  download_folder="/tmp/"
  download_file="privatebin_latest.tar.gz"
  date_folder="$(date '+%Y%m%d')"
  
  # Move the old PrivateBin installation
  mv "$pbin_folder" "$pbin_folder"_old_"$date_folder"
  
  # Download the newest PrivateBin installation
  tarball_url="$(wget -q -O - "$download_url_latest" | jq -r '.tarball_url')"
  wget "$tarball_url" -q -O "$output_folder""$download_file"
  
  # Extract the tarball
  tar -zxvf "$output_folder""$download_file" -C "$output_folder"
  
  # Check the name of the extracted folder and move it to installation path
  wrong_folder_name="$(tar --exclude="*/*" -tf "$output_folder""$download_file")"
  mv "$output_folder""$wrong_folder_name" "$pbin_folder"
  
  # Create data folder and copy old data into it
  mkdir "$pbin_folder"/data
  cp -r "$pbin_folder"_old_"$date_folder"/data "$pbin_folder"/
  chown -R www-data:www-data "$pbin_folder"/data
  
  rm "$output_folder""$download_file"
  ~~~

## Configuration on Debian/Ubuntu

  ~~~
  sudo apt install -y apache2 php
  sudo vim /etc/apache2/sites-available/privatebin.conf

  <VirtualHost *:80>
      ServerName pbin
      DocumentRoot /var/www/privatebin.domain.com/
      ErrorLog ${APACHE_LOG_DIR}/privatebin-error.log
      CustomLog ${APACHE_LOG_DIR}/privatebin-access.log combined
      <Directory "/var/www/privatebin.domain.com">
          AllowOverride All
      </Directory>
  </VirtualHost>

  sudo a2ensite privatebin.conf
  sudo systemctl reload apache2
  ~~~

## Configuration on CentOS 8
    * PHP 7.4 wasn't enabled by default, for some reason 7.2 didn't work properly
        ~~~
        # Check newest php
        yum module list php
        yum module enable php:7.4
        yum install php
        ~~~
    * One needed to start and enable php-fpm service after installation
        ~~~
        systemctl start php-fpm
        systemctl enable php-fpm
        ~~~
      * Otherwise there will be error in httpd logs
          ~~~ 
          [Thu May 27 12:57:27.993607 2021] [proxy:error] [pid 560232:tid 139909071324928] (2)No such file or directory: AH02454: FCGI: attempt to connect to Unix domain socket /run/php-fpm/www.sock (*) failed
          [Thu May 27 12:57:27.993706 2021] [proxy_fcgi:error] [pid 560232:tid 139909071324928] [client IP:49672] AH01079: failed to make connection to backend: httpd-UDS
          pbin-error-https.log (END)
          ~~~
    * PHP versions on CentOS 8
        ~~~
        php --version
            PHP 7.2.24 (cli) (built: Oct 22 2019 08:28:36) ( NTS )
            Copyright (c) 1997-2018 The PHP Group
            Zend Engine v3.2.0, Copyright (c) 1998-2018 Zend Technologies

        php-fpm --version
            PHP 7.2.24 (fpm-fcgi) (built: Oct 22 2019 08:28:36)
            Copyright (c) 1997-2018 The PHP Group
            Zend Engine v3.2.0, Copyright (c) 1998-2018 Zend Technologies
        ~~~
    * SELinux might need set context's correctly
      * Not completely sure about this...
      ~~~
      semanage fcontext -a -t httpd_sys_rw_content_t PrivateBin
      restorecon -R -v PrivateBin
      ~~~  
* Additionally you need to configure either HTTPS on the server or HTTPS for proxying.

* Configuration file for Apache reverse proxy

  ~~~
  <VirtualHost *:80>
      ServerName pbin.domain.com
      ServerAdmin admin@domain.com
      DocumentRoot /var/www/html

      ErrorLog /var/log/httpd/pbin-error.log
      CustomLog /var/log/httpd/pbin-access.log combined

      RewriteEngine on
      RewriteCond %{SERVER_NAME} =pbin.domain.com
      RewriteRule ^ https://%{SERVER_NAME}%{REQUEST_URI} [END,NE,R=permanent]
  </VirtualHost>

  <IfModule mod_ssl.c>
  <VirtualHost *:443>
      ServerName pbin.domain.com
      ServerAdmin admin@domain.com
      DocumentRoot /var/www/html

      ErrorLog /var/log/httpd/pbin-error-https.log
      CustomLog /var/log/httpd/pbin-access-https.log combined

      <Directory "/var/www/html">
          Options Indexes FollowSymLinks MultiViews
          # Show full file names
          <IfModule mod_autoindex.c>
              IndexOptions NameWidth=*
          </IfModule>

          # There's "/var/www/html" configuration in /etc/httpd/conf/httpd.conf file in CentOS 7
          # That configuration has been commmented out, so they are not conflicting these configurations.
          # https://stackoverflow.com/questions/8551740/centos-htaccess-not-being-read
          # AllowOverride All for .htaccess <If>
          AllowOverride All
          Order allow,deny
          allow from all

          # Ä and Ö
          IndexOptions +Charset=UTF-8

      </Directory>

      <Location "/">
          ProxyPass           http://pbin.localdomain.com:80/
          ProxyPassReverse    http://pbin.localdomain.com:80/
      </Location>

  SSLCertificateFile /etc/letsencrypt/live/pbin.domain.com/fullchain.pem
  SSLCertificateKeyFile /etc/letsencrypt/live/pbin.domain.com/privkey.pem
  Include /etc/letsencrypt/options-ssl-apache.conf
  </VirtualHost>
  </IfModule>
  ~~~
