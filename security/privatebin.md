# How to install, configure and use PrivateBin

* PrivateBin is a service for sending sensitive data over browser links
* https://nxnjz.net/2019/02/how-to-install-privatebin-on-debian-9/

* Installation

  ~~~
  sudo apt install -y apache2 php
  sudo vim /etc/apache2/sites-available/privatebin.conf

  <VirtualHost *:80>
  ServerName pbin
  DocumentRoot /var/www/html/PrivateBin/
  ErrorLog ${APACHE_LOG_DIR}/privatebin-error.log
  CustomLog ${APACHE_LOG_DIR}/privatebin-access.log combined
  <Directory /var/www/html/PrivateBin>
  AllowOverride All
  </Directory>
  </VirtualHost>

  sudo a2ensite privatebin.conf
  sudo systemctl reload apache2

  cd /var/www/html/ && sudo git clone https://github.com/PrivateBin/PrivateBin.git

  sudo chown -R www-data:www-data PrivateBin/
  ~~~

* Additionally you need to configure either HTTPS on the server or HTTPS for proxying

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
