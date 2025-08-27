# WordPress instructions

## How to migrate WordPress from server/service provider to another

1. Backup current WordPress installation.
    * One can use [Duplicator](https://wordpress.org/plugins/duplicator/) plugin for backing up WordPress site.
    * Or one can backup database and WordPress files and create database backup.

      ~~~sh
      db="wpdb"
      dbuser="dbuser"
      dbhost="database.host.example.com"
      dumppath="/mnt/some/path/"
      sudo mysqldump \
          "$db" \
          --single-transaction \
          --order-by-primary \
          --result-file="$dumppath""$db"_$(date +"%Y-%m-%d%H-%M").sql \
          -u "$dbuser" \
          -h "$dbhost" \
          -P 3306 \
          -p
      ~~~

1. Connect to the new mysql instance and create a new database.

    1. Connect to mysql instance

        ~~~sh
        mysql -h mysql -P 3306 -u root -p
        ~~~

    1. Create a new database

        ~~~sql
        CREATE DATABASE database_name CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
        CREATE USER 'database_user'@'%' IDENTIFIED BY 'complicated_password';
        GRANT SELECT,INSERT,UPDATE,DELETE,CREATE,DROP,ALTER ON database_name.* TO 'database_user'@'%';
        GRANT ALL ON database_name.* TO 'database_user'@'%';
        FLUSH PRIVILEGES;
        \q
        ~~~

1. Restore WordPress database and files
    * If Duplicator was used to backup, run <https://wp.example.com/installer.php>
        * If the WordPress is running in an Apache2/httpd (or other webserver) container behind a load balancer or a reverse proxy, Apache2 config file might need the HTTPS directives as instructed in [Apache2 behind a HTTPS reverse proxy](../apache2_httpd/README.md).

          ~~~text
          The information you have entered on this page will be sent over an insecure connection and could be read by a third party.

          Are you sure you want to send this information?
          ~~~

    * If file backup and database dump was created, restore database and then files.

        ~~~sh
        dbuser="dbuser"
        dbhost="database.host.example.com"
        dbdump="./wpdbproddb_2024-07-1414-54.sql"
        newdb="wpdb01"
        mysql -h "$dbhost" \
            -P 3306 \
            -u "$dbuser" \
            -p \
            "$newdb" < "$dbdump"
        ~~~

1. If file permissions need fixing, one can run commands below.

    ~~~sh
    # cd to the WordPress root directory
    sudo find . -type d -exec chmod 755 {} \;
    sudo find . -type f -exec chmod 644 {} \;
    sudo chown -R www-data: .
    ~~~

1. Sometimes `wp-config.php` needs tweaking with some of the setting below.

    Add the settings between `$table_prefix = 'wp_';` and `if ( ! defined( 'ABSPATH' ) ) {`. One can check `wp-config-sample.php` for an example.

    ~~~php
    #### START ADDING wp-config.php
    define('WP_CONTENT_URL','https://wp.example.com/wp-content/');

    # Set HTTPS
    $_SERVER['HTTPS'] = 'on';
    $_SERVER['REQUEST_SCHEME'] = 'https';

    # Below settings might be useful or not

    # One time plugins did not update without this
    #define('FS_METHOD', 'direct');

    #define('WP_HOME','https://wp.example.com/');
    #define('WP_SITEURL','https://wp.example.com/');

    # Debug log is written into wp-content/debug.log
    #define('WP_DEBUG', true);
    #define('WP_DEBUG_LOG', true);
    #define('WP_DEBUG_DISPLAY', false);

    #define('WP_CONTENT_DIR','/var/www/html/wp-content');
    ##### END ADDING
    ~~~

1. If one wants to change the URL of the site (http -> https or wp.example.com -> wp.otherdomain.com), one can use [WP-CLI](https://developer.wordpress.org/cli/commands/search-replace/). WP-CLI works with serialized data.

    **NOTICE**: some CSS/etc files could have the URL hard-coded.

    One can install the WP-CLI on the host server, or connect with a container. Here are instructions to install and use WP-CLI on debian:bookworm Docker container
    * **NOTICE**: one should not use the WP-CLI as root on the real WordPress host.

    ~~~sh
    # Open Bash in the container then run commands below.
    apt-get update
    apt-get install -y curl php vim default-mysql-client php-mysqli
    curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
    chmod +x wp-cli.phar
    mv wp-cli.phar /usr/local/bin/wp

    wp --info
        OS:     Linux 6.1.0-23-amd64 #1 SMP PREEMPT_DYNAMIC Debian 6.1.99-1 (2024-07-15) x86_64
        Shell:
        PHP binary:     /usr/bin/php8.2
        PHP version:    8.2.28
        php.ini used:   /etc/php/8.2/cli/php.ini
        MySQL binary:
        MySQL version:
        SQL modes:
        WP-CLI root dir:        phar://wp-cli.phar/vendor/wp-cli/wp-cli
        WP-CLI vendor dir:      phar://wp-cli.phar/vendor
        WP_CLI phar path:       phar:///usr/local/bin/wp
        WP-CLI packages dir:
        WP-CLI cache dir:       /root/.wp-cli/cache
        WP-CLI global config:
        WP-CLI project config:
        WP-CLI version: 2.12.0
        
    mkdir /opt/wp
    cd /opt/wp
    wp core download --allow-root
    # Configure wp-config.php with the new database credentials and settings.
    cp wp-config-sample.php wp-config.php
    vim wp-config.php

    # Test connection to database. This opens connection without anything printed.
    wp db query --allow-root

    # --skip-columns=guid is debatable. If one leaves it out, all posts are "reposted".
    wp search-replace 'https://wp.example.com' 'https://wp.anotherdomain.com' --skip-columns=guid
    ~~~

## Disable lockout for certain IP

When trying to login there might be an error similar to below.

~~~text
ERROR: Too many failed login attempts. Please try again in 24 hours.
~~~

One fix could be to white list an IP via MySQL.

~~~sql
SELECT * FROM wp_options WHERE option_name LIKE 'limit_login_lockouts';

+-----------+----------------------+--------------------------------------------+----------+
| option_id | option_name          | option_value                               | autoload |
+-----------+----------------------+--------------------------------------------+----------+
|       925 | limit_login_lockouts | a:1:{s:10:"123.123.123.123";i:1753130203;} | off      |
+-----------+----------------------+--------------------------------------------+----------+

UPDATE wp_options SET option_value = REPLACE(option_value, '123.123.123.123', '124.124.124.124') WHERE option_name = 'limit_login_lockouts' LIMIT 1;

SELECT * FROM wp_options WHERE option_name LIKE 'limit_login_lockouts';
+-----------+----------------------+--------------------------------------------+----------+
| option_id | option_name          | option_value                               | autoload |
+-----------+----------------------+--------------------------------------------+----------+
|       925 | limit_login_lockouts | a:1:{s:10:"124.124.124.124";i:1753130203;} | off      |
+-----------+----------------------+--------------------------------------------+----------+
~~~
