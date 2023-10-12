# Tricks for macOS


### OpenSSL
* By default macOS Big Sur 11.1 uses LibreSSL which a bit limited.
  ~~~
  # Check version in use
  openssl version                                                                                        

  LibreSSL 2.8.3                   
  ~~~

* To install OpenSSL with Homebrew run commands:
  ~~~
  brew update
  brew install openssl
  echo 'export PATH="/usr/local/opt/openssl/bin:$PATH"' >> ~/.bash_profile
  source ~/.bash_profile

  # Check version in use
  openssl version

  OpenSSL 1.1.1i  8 Dec 2020
  ~~~

### How to make a script to start at boot
* Notice that this script will be run as root user.
* Source: https://medium.com/@fahimhossain_16989/adding-startup-scripts-to-launch-daemon-on-mac-os-x-sierra-10-12-6-7e0318c74de1
  * This Gist is mentioned in the source. There are useful options.
    * https://gist.github.com/fahim0173/f91e24e490acd7c32ad80bae12e8c227

1. Create a test script `/opt/scripts/test_script.bash`
    ~~~
    #!/bin/bash
    echo $(date) >> /opt/scripts/test.txt
    ~~~
1. Make the script executable
    ~~~
    chmod u+x  test_script.bash
    ~~~
1. Test that the script writes date into the test.txt file
    ~~~
    sudo ./test_script.bash

    cat test.txt 
    Sat Sep 18 12:58:51 CEST 2021
    ~~~
1. Make a plist file which defines the Launch Daemon behavior
    * `/Library/LaunchDaemons/com.startup.plist`
        ~~~ 
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
        <plist version="1.0">
        <dict>
           <key>Label</key>
              <string>com.startup</string>
           <key>Program</key>
              <string>/opt/scripts/test_script.bash</string>
           <key>RunAtLoad</key>
              <true/>
           <key>StandardOutPath</key>
              <string>/tmp/startup.stdout</string>
           <key>StandardErrorPath</key>
              <string>/tmp/startup.stderr</string>
        </dict>
        </plist>
        ~~~
1. Test the plist. By runnign the command below the plist is run and there should be a new date in the test.txt
    ~~~
    sudo launchctl start com.startup
    ~~~
1. Add the plist into launchctl
    ~~~
    sudo launchctl load -w /Library/LaunchDaemons/com.startup.plist
    ~~~
1. Check that the plist is in the launchctl list
    ~~~
    sudo launchctl list | grep com.startup
    -	1	com.startup
    ~~~
1. Restart your Mac and check if there's new date in the test.txt

* One can disable the plist from launchctl
    ~~~
    sudo launchctl unload -w /Library/LaunchDaemons/com.startup.plist
    ~~~

### Google Remote Desktop
#### How to copy paste from Windows into Mac
* On the Session options right, opens via the arrow, select Configure key mappings and map:

  | From | To |
  |------|----|
  |ControlLeft| MetaLeft |

