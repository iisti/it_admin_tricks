# Golang instructions

## Install Golang

### Linux

* Tested on WSL2 Debian 11
* Check the latest version from https://go.dev/dl/

~~~
go_version="1.23.0"
cd /tmp
curl -LO https://go.dev/dl/go"$go_version".linux-amd64.tar.gz
tar -C /usr/local -xzf go"$go_version".linux-amd64.tar.gz
cat << 'EOF' >> ~/.bashrc

# For golang
export PATH=$PATH:/usr/local/go/bin
EOF
cd -
~~~
