# How to run Alfresco in Docker container

* [Wikipedia](https://en.wikipedia.org/wiki/Alfresco_Software): Alfresco is a collection of information management software products for Microsoft Windows and Unix-like operating systems developed by Alfresco Software Inc. using Java technology.

## Install Docker and Docker-Compose on Debian
* Debian 10 was used.
* Check [docker_install.md](docker_install.md)

## Deploy Alfresco
* Source: https://docs.alfresco.com/content-services/community/install/containers/docker-compose/
~~~
cd /opt; \
sudo git clone https://github.com/Alfresco/acs-deployment.git; \
cd acs-deployment
~~~

## Configure docker-compose.yml
~~~
sudo vim /opt/acs-deployment/docker-compose/docker-compose.yml
~~~
