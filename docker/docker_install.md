# Install Docker

## Install Docker Debian

* Tested with Debian 10 and 11
* Source: https://docs.docker.com/engine/install/debian/
    ~~~
    # Setup the repository
    sudo apt-get install \
        apt-transport-https \
        ca-certificates \
        curl \
        gnupg \
        lsb-release; \
    curl -fsSL https://download.docker.com/linux/debian/gpg | \
        sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg; \
    echo \
        "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian \
        $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    # Install Docker Engine
    sudo apt-get update; \
    sudo apt-get install docker-ce docker-ce-cli containerd.io

    # Add current user and root to group "docker".
    sudo usermod -aG docker $(whoami) && \
    sudo usermod -aG docker root
    ~~~

## Install Docker Desktop on Windows

Source https://docs.docker.com/desktop/install/windows-install/

* PowerShell

    ~~~
    cd ~/Downloads
    Invoke-WebRequest -URI "https://desktop.docker.com/win/main/amd64/Docker%20Desktop%20Installer.exe" -OutFile "./Docker Desktop Installer.exe"
    Start-Process 'Docker Desktop Installer.exe' -Wait install
    ~~~

## Install Docker CentOS, Rocky Linux
* Tested with CentOS 7, 8 and Rocky Linux 8, 9.
* Source: https://docs.docker.com/engine/install/centos/
    ~~~
    sudo yum update; \
    sudo yum install -y yum-utils; \
    sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo; \
    sudo yum install docker-ce docker-ce-cli containerd.io; \
    sudo systemctl start docker

    # Check that docker works if you're unfamiliar with docker.
    sudo docker run hello-world

    # Add current user and root to group "docker".
    sudo usermod -aG docker $(whoami) && \
    sudo usermod -aG docker root
    
    # Enable Docker service
    sudo systemctl enable docker
    ~~~

## Changing Docker data root directory
1. Stop the Docker services:
    ~~~
    sudo systemctl stop docker
    sudo systemctl stop docker.socket
    sudo systemctl stop containerd
    ~~~
1. Create new Docker data root directory
    ~~~
    sudo mkdir -p /new_dir_structure
    ~~~
1. Move Docker root to the new directory structure:
    ~~~
    sudo mv /var/lib/docker /new_dir_structure
    ~~~
1. Edit the file /etc/docker/daemon.json. If the file does not exist, create the file by running the following command:
    ~~~
    sudo vim /etc/docker/daemon.json
    ~~~
1. Add the following information to this file:
    ~~~
    {
      "data-root": "/new_dir_structure/docker"
    }
    ~~~
1. After the /etc/docker/daemon.json file is saved and closed, restart the Docker services:
    ~~~
    sudo systemctl start docker
    ~~~
1. After you run the command, all Docker services through dependency management will restart.
    * Validate the new Docker root location:
        ~~~
        docker info -f '{{ .DockerRootDir}}'
        ~~~

## Install Docker-Compose

### Docker Compose v2
* Check the newest version https://github.com/docker/compose/releases
* Source: https://docs.docker.com/compose/cli-command/#install-on-linux
   * Install for all users

       ~~~
       compose_version="v2.27.0" && \
       sudo mkdir -p /usr/local/lib/docker/cli-plugins && \
       sudo curl -SL https://github.com/docker/compose/releases/download/"$compose_version"/docker-compose-linux-x86_64 -o /usr/local/lib/docker/cli-plugins/docker-compose && \
       sudo chmod +x /usr/local/lib/docker/cli-plugins/docker-compose
       ~~~
   * Install per user

       ~~~
       compose_version="v2.14.2" && \
       DOCKER_CONFIG=${DOCKER_CONFIG:-$HOME/.docker} && \
       mkdir -p $DOCKER_CONFIG/cli-plugins && \
       curl -SL https://github.com/docker/compose/releases/download/"$compose_version"/docker-compose-linux-x86_64 -o $DOCKER_CONFIG/cli-plugins/docker-compose
       chmod +x $DOCKER_CONFIG/cli-plugins/docker-compose
       ~~~

   * Test

       ~~~
       docker compose version
          # Docker Compose version v2.x.y
       ~~~

### Docker Compose v1
* Source: <https://docs.docker.com/compose/install/>

   ~~~
   sudo curl -L "https://github.com/docker/compose/releases/download/1.29.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose; \
   sudo chmod +x /usr/local/bin/docker-compose; \
   docker-compose --version
   ~~~
