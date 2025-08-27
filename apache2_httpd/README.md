# Apache2 / httpd instructions

## Apache2 behind a HTTPS reverse proxy

If the site is running on Apache2 container behind a reverse proxy, Apache2 configuration might need these settings to get the HTTPS working properly. These are set in the `<VirtualHost *:80>` block. Similar settings are probably needed for nginx or other web servers.

Without the directives browsers could give warnings similar to below. The below warninig is from a Firefox pop-up.

~~~text
The information you have entered on this page will be sent over an insecure connection and could be read by a third party.

Are you sure you want to send this information?
~~~

**NOTICE**: A URL is defined in one of the directives.

~~~sh
RequestHeader set X-Forwarded-Port "443" early
# Without this some of the requests might be sent as http.
RequestHeader set X-Forwarded-Proto "https" early
# Without this there might be "Blocked loading mixed active content" errors in browser console.
Header always set Content-Security-Policy "upgrade-insecure-requests"
~~~

* This snip adds the settings after DocumentRoot directive in the `000-default.conf`.

  ~~~sh
  sed -i '/DocumentRoot/a RequestHeader set X-Forwarded-Port \"443\" early' /etc/apache2/sites-available/000-default.conf &&
  sed -i '/DocumentRoot/a RequestHeader set X-Forwarded-Proto \"https\" early' /etc/apache2/sites-available/000-default.conf &&
  sed -i '/DocumentRoot/a Header always set Content-Security-Policy \"upgrade-insecure-requests\"' /etc/apache2/sites-available/000-default.conf &&
  cat /etc/apache2/sites-available/000-default.conf && 
  a2enmod headers
  ~~~

### Log client IP when behind reverse proxy

Add the following lines to any specific Apache2 site configuration.

~~~sh
<VirtualHost *:80>
    # Place holder for other site configuration

    # Log with RemoteIP / ClientIP
    SetEnvIf X-Forwarded-For "^.*\..*\..*\..*" forwarded
    LogFormat "%a %l %u %t \"%r\" %>s %O \"%{Referer}i\" \"%{User-Agent}i\"" combined
    LogFormat "%{X-Forwarded-For}i %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\"" forwarded
    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined env=!forwarded
    CustomLog ${APACHE_LOG_DIR}/access.log forwarded env=forwarded
</VirtualHost>
~~~

* NOTE: `SetEnvIf X-Forwarded-For "^(\d{1,3}+\.\d{1,3}+\.\d{1,3}+\.\d{1,3}+).*" XFFCLIENTIP=$1` could be useful for extracting the client IP. Source https://stackoverflow.com/a/10346093/3498768
