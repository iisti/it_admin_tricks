# Golang instructions

## Install Golang

### Linux

Tested on WSL2 Debian 11.

Check the latest version from https://go.dev/dl/

1. Install

    ~~~sh
    go_version="1.23.4"
    
    # Create temp dir
    tmp=$(mktemp -d)
    cd $tmp || exit 1
    
    # Download and extract Go
    curl -LO https://go.dev/dl/go"$go_version".linux-amd64.tar.gz
    sudo tar -C /usr/local -xzf go"$go_version".linux-amd64.tar.gz
    cd -
  
    # Remove temp dir
    rm -rf $tmp
    ~~~

1. Add PATH

      ~~~sh
      # Add path
      cat << 'EOF' >> ~/.bashrc
      
      # For golang
      export PATH=$PATH:/usr/local/go/bin
      EOF
      ~~~

## Update Golang

### Linux

Tested on WSL2 Debian 11.

1. Remove previous installation

    ~~~sh
    # Remove Go
    goroot=$(which go | rev | cut -d'/' -f3- | rev)
    sudo rm -rf "$goroot"
    ~~~

1. Run the installation commands above.
