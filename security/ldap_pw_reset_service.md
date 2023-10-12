# LDAP Tool Box Self Service Password

* Sources:
    * https://self-service-password.readthedocs.io/en/latest/installation.html
    * https://github.com/ltb-project/self-service-password

## Install on Debian
* Install apache2, php and gnupg (required by "apt-key add").
    ~~~
    sudo apt install -y apache2 php gnupg
    ~~~

* Debian 10 Buster install
    ~~~
    echo "deb [arch=amd64] https://ltb-project.org/debian/stable stable main"  | sudo tee -a /etc/apt/sources.list.d/ltb-project.list
    wget -O - https://ltb-project.org/wiki/lib/RPM-GPG-KEY-LTB-project | sudo apt-key add -
    sudo apt update
    sudo apt install self-service-password
    ~~~

### Apache configuration
* Source: https://self-service-password.readthedocs.io/en/latest/config_apache.html
* There's default configuration installed in Debian.
    ~~~
    cd /etc/apache2/sites-available
    sudo cp self-service-password.conf self-service-password.conf.orig
    sudo vim self-service-password.conf
    ~~~
    * Set ServerName
        ~~~
        <VirtualHost *:80>
            ServerName ssp.domain.com
            DocumentRoot /usr/share/self-service-password/htdocs
            DirectoryIndex index.php
            AddDefaultCharset UTF-8

            <Directory /usr/share/self-service-password/htdocs>
                AllowOverride None
                <IfVersion >= 2.3>
                    Require all granted
                </IfVersion>
                <IfVersion < 2.3>
                    Order Deny,Allow
                    Allow from all
                </IfVersion>
            </Directory>

            Alias /rest /usr/share/self-service-password/rest

            <Directory /usr/share/self-service-password/rest>
                AllowOverride None
                <IfVersion >= 2.3>
                    Require all denied
                </IfVersion>
                <IfVersion < 2.3>
                    Order Deny,Allow
                    Deny from all
                </IfVersion>
            </Directory>

            LogLevel warn
            ErrorLog /var/log/apache2/ssp_error.log
            CustomLog /var/log/apache2/ssp_access.log combined
        </VirtualHost>
        
        # vim: syntax=apache ts=4 sw=4 sts=4 sr noet
        ~~~
        * Test config and reload Apache
            ~~~
            sudo apachectl configtest
            sudo systemctl reload apache2
            ~~~
            
### Configure Self-Service-Password for Microsoft AD
* Noticee that Samba 4 should work with these settings also, though this hasn't been tested.
* Configuration file
    ~~~
    /usr/share/self-service-password/conf/config.inc.php
    ~~~  
* Change the keyphrase on line: `$keyphrase = "secret";` otherwise there is error:
    ~~~
    Token encryption requires a random string in keyphrase setting 
    ~~~
* Set LDAP settings
    ~~~
    # LDAP
    $ldap_url = "ldap://dc01.domain.com:389";
    $ldap_starttls = false;
    $ldap_binddn = "CN=binduser,OU=Accounts,domain,DC=com";
    $ldap_bindpw = 'censored';
    $ldap_base = "OU=Accounts,domain,DC=com";
    $ldap_login_attribute = "uid";
    $ldap_fullname_attribute = "cn";
    #$ldap_filter = "(&(objectClass=person)($ldap_login_attribute={login}))";
    $ldap_filter = "(&(objectClass=user)(sAMAccountName={login})(!(userAccountControl:1.2.840.113556.1.4.803:=2)))";
    $ldap_use_exop_passwd = false;
    $ldap_use_ppolicy_control = false;
    ~~~
* Set Active Directory mode, set false -> true:
    ~~~
    $ad_mode = true;
    ~~~
* Disable Question and SMS, set true -> false:
    ~~~
    $use_questions = false;
    $use_sms = false;
    ~~~
    * Notice that password reset via email token requires defining a bind account which can do password resets. This is a bit of a security risk, so also tokens were disabled.
        ~~~
        $use_tokens = false;
        ~~~
        * Quote from https://self-service-password.readthedocs.io/en/latest/config_ldap.html#credentials   
            ~~~
            The user account can only be used for standard password change, when user is giving its old password. For other password changes (token, questions, …), manager account will always be used, whatever value is set in $who_change_password.
            ~~~
* Configure Email

    * Notice that Google SMTP relay service has to be configured that smtp-relay.gmail.com host can be used.
        * https://support.google.com/a/answer/176600?hl=en
    ~~~
    ## Mail
    # LDAP mail attribute
    $mail_attribute = "mail";
    # Get mail address directly from LDAP (only first mail entry)
    # and hide mail input field
    # default = false
    $mail_address_use_ldap = false;
    # Who the email should come from
    $mail_from = "noreply@domain.com";
    $mail_from_name = "Self Service Password";
    $mail_signature = "";
    # Notify users anytime their password is changed
    $notify_on_change = false;
    # PHPMailer configuration (see https://github.com/PHPMailer/PHPMailer)
    $mail_sendmailpath = '/usr/sbin/sendmail';
    $mail_protocol = 'smtp';
    $mail_smtp_debug = 0;
    $mail_debug_format = 'error_log';
    $mail_smtp_host = 'smtp-relay.gmail.com';
    $mail_smtp_auth = false;
    $mail_smtp_user = '';
    $mail_smtp_pass = '';
    $mail_smtp_port = 587;
    $mail_smtp_timeout = 30;
    $mail_smtp_keepalive = false;
    $mail_smtp_secure = 'tls';
    $mail_smtp_autotls = true;
    $mail_smtp_options = array();
    $mail_contenttype = 'text/plain';
    $mail_wordwrap = 0;
    $mail_charset = 'utf-8';
    $mail_priority = 3;
    ~~~
* Now sending a reset email should work, but if one doesn't enable TLS on AD LDAP, AD will refuse to reset a password.
    * Error: Password was refused by the LDAP directory
* Next step is to enable LDAPS and maybe set `$reset_url` if behind reverse proxy.
    ~~~
    # Reset URL (if behind a reverse proxy)
    #$reset_url = $_SERVER['HTTP_X_FORWARDED_PROTO'] . "://" . $_SERVER['HTTP_X_FORWARDED_HOST'] . $_SERVER['SCRIPT_NAME'];
    ~~~
