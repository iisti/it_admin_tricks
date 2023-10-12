# Install he latest NPM and NodeJS

## Debian WSL
* https://tecadmin.net/install-latest-nodejs-npm-on-debian/

* Install the latest the latest
    ~~~
    sudo apt install curl software-properties-common 
    curl -sL https://deb.nodesource.com/setup_16.x | sudo bash - 
    sudo apt-get install -y nodejs
    node -v
        # v16.2.0
    npm -v
        # 7.13.0
    ~~~
