# Install and configure sqlcmd
* sqlcmd is a tool for connecting into MSSQL servers via command line. The tool can be installed on Windows, Linux and MacOS.

## Install Debian 10
* Source https://docs.microsoft.com/en-us/sql/linux/sql-server-linux-setup-tools?view=sql-server-ver15#ubuntu
    ~~~
    sudo echo "Installing gnupg2 for handling repository GPG keys"; \
    sudo apt update && sudo apt install -y gnupg2; \
    echo "Importing the public repository GPG keys"; \
    curl https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -; \
    echo "Registering the Microsoft Ubuntu repository"; \
    curl https://packages.microsoft.com/config/ubuntu/20.04/prod.list | sudo tee /etc/apt/sources.list.d/msprod.list; \
    echo "Updating the sources list and run the installation command with the unixODBC developer package."; \
    sudo apt update; \
    sudo apt install mssql-tools unixodbc-dev; \
    echo "Adding /opt/mssql-tools/bin/ to your PATH environment variable in a bash shell." ; \
    echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bash_profile; \
    source ~/.bash_profile; \
    sqlcmd -?
    ~~~

# Run query and write output into CSV
* One can use sqlcmd (Windows, Linux, OSX) for retrieving the login information.
    * Save the query above as query.sql
    * -W = remove trailing spaces from every field
    * -s = separate with comma
    * -o = output file
    ~~~
    sqlcmd -S <FQDN_of_database_server> -d <database_name> -U <database_user> -i ./query.sql -W -s"," -o "output.csv"
    ~~~
