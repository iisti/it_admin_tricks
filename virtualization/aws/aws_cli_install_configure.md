# How to install/configure AWS CLI

## Debian WSL (Windows Subsystem Linux)

* Checking WSL version from PowerShell
    ~~~
    wsl --list --verbose
    NAME      STATE           VERSION
    * Debian    Running         1
    ~~~

### Install the latest AWS CLI
* Source https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2-linux.html#cliv2-linux-install
    ~~~
    sudo apt install -y curl unzip && \
    cd && \
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    sudo ./aws/install && \
    aws --version

    # Remove installation files
    rm awscliv2.zip && \
    rm -r aws
    ~~~
* If one needs to use help as in "aws help", groff needs to be installed. Otherwise there will be error `Could not find executable named "groff"`
    * If one wants to keep installation size as small as possible it's not recommendable to install groff as the whole installation took 200M with Debian WSL.
    ~~~
    apt install groff
    ~~~

### Basic configuration of AWS CLI
* Run command to configure. Create AWS Access KEY ID and secret access key in AWS web console. Note that one can have only 2 keys at the same time.
    ~~~
    aws configure

    AWS Access Key ID [None]: <censored>
    AWS Secret Access Key [None]: <censored>
    Default region name [None]: eu-west-1
    Default output format [None]: json
    ~~~
