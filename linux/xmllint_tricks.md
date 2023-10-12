# XMLLint tricks

## How to install
* Debian based Linux
    ~~~
    sudo apt-get install -y libxml2-utils
    ~~~
* RHEL base Linux
    ~~~
    sudo yum install -y xmlstarlet
    ~~~

## How to extract string/element from XML/HTML tag
* There's a file dbconfig.xml
    ~~~
    <password>supersecurepw</password>
    ~~~
* The password can be extracted with command below.
    ~~~
    xmllint --xpath "string(//password)" dbconfig.xml
    ~~~
    * Output is
        ~~~
        supersecurepw
        ~~~
