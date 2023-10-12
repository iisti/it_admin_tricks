
# CentOS 8
* The newest configuration file can be found from:
* https://tomcat.apache.org/download-connectors.cgi

## Install httpd

  ~~~
  sudo yum install httpd
  ~~~

## Check if mod_jk is enabled

  ~~~
  sudo httpd -M | grep jk
  ~~~

## Installing/compiling mod_jk

* Compiling mod_jk

  ~~~
  dnf install httpd-devel make libtool
  mkdir compile_mod_jk

  wget https://mirror.klaus-uwe.me/apache/tomcat/tomcat-connectors/jk/tomcat-connectors-1.2.48-src.tar.gz

  tar -xvf tomcat-connectors-1.2.48-src.tar.gz
  cd tomcat-connectors-1.2.48-src/native

  ./configure -with-apxs=/usr/bin/apxs

  sudo yum install redhat-rpm-config
  # Otherwise error:
  # gcc: error: /usr/lib/rpm/redhat/redhat-hardened-cc1: No such file or directory

  make

  libtool --finish /usr/lib64/httpd/modules
  # is this needed?
  #sudo make install
  ~~~

* Creating a httpd configuration file for the mod_jk, this basicly enables the module
  ~~~
  sudo tee /etc/httpd/conf.modules.d/20-jk.conf <<EOF
  LoadModule      jk_module modules/mod_jk.so
  <IfModule jk_module>
      JkWorkersFile   conf.d/workers.properties
      JkShmFile       /var/run/mod_jk/
      JkLogFile       logs/mod_jk.log
      JkLogLevel info
  </IfModule>
  EOF
  ~~~

* workers.properties from Debian 10.
  * This is installed by default in Debian and is more usable than the one created by default in `tomcat-connectors-1.2.48-src/conf`
  ~~~
  # workers.properties -
  #
  # This file is a simplified version of the workers.properties supplied
  # with the upstream sources. The jni inprocess worker (not build in the
  # debian package) section and the ajp12 (deprecated) section are removed.
  #
  # As a general note, the characters $( and ) are used internally to define
  # macros. Do not use them in your own configuration!!!
  #
  # Whenever you see a set of lines such as:
  # x=value
  # y=$(x)\something
  #
  # the final value for y will be value\something
  #
  # Normaly all you will need to do is un-comment and modify the first three
  # properties, i.e. workers.tomcat_home, workers.java_home and ps.
  # Most of the configuration is derived from these.
  #
  # When you are done updating workers.tomcat_home, workers.java_home and ps
  # you should have 3 workers configured:
  #
  # - An ajp13 worker that connects to localhost:8009
  # - A load balancer worker
  #
  #

  # OPTIONS ( very important for jni mode )

  #
  # workers.tomcat_home should point to the location where you
  # installed tomcat. This is where you have your conf, webapps and lib
  # directories.
  #
  workers.tomcat_home=/usr/share/tomcat8

  #
  # workers.java_home should point to your Java installation. Normally
  # you should have a bin and lib directories beneath it.
  #
  workers.java_home=/usr/lib/jvm/default-java

  #
  # You should configure your environment slash... ps=\ on NT and / on UNIX
  # and maybe something different elsewhere.
  #
  ps=/

  #
  #------ ADVANCED MODE ------------------------------------------------
  #---------------------------------------------------------------------
  #

  #
  #------ worker list ------------------------------------------
  #---------------------------------------------------------------------
  #
  #
  # The workers that your plugins should create and work with
  #
  worker.list=ajp13_worker

  #
  #------ ajp13_worker WORKER DEFINITION ------------------------------
  #---------------------------------------------------------------------
  #

  #
  # Defining a worker named ajp13_worker and of type ajp13
  # Note that the name and the type do not have to match.
  #
  worker.ajp13_worker.port=8009
  worker.ajp13_worker.host=localhost
  worker.ajp13_worker.type=ajp13
  #
  # Specifies the load balance factor when used with
  # a load balancing worker.
  # Note:
  #  ----> lbfactor must be > 0
  #  ----> Low lbfactor means less work done by the worker.
  worker.ajp13_worker.lbfactor=1

  #
  # Specify the size of the open connection cache.
  #worker.ajp13_worker.cachesize

  #
  #------ DEFAULT LOAD BALANCER WORKER DEFINITION ----------------------
  #---------------------------------------------------------------------
  #

  #
  # The loadbalancer (type lb) workers perform wighted round-robin
  # load balancing with sticky sessions.
  # Note:
  #  ----> If a worker dies, the load balancer will check its state
  #        once in a while. Until then all work is redirected to peer
  #        workers.
  worker.loadbalancer.type=lb
  worker.loadbalancer.balance_workers=ajp13_worker
  ~~~


# SELinux Linux configurations

* If not configured, there will be error starting httpd:

    ~~~
    SELinux is preventing httpd from map access on the file /var/run/mod_jk/jk-runtime-status.774904
    ~~~
1. Create folder for mod_jk run time files
    ~~~
    sudo mkdir /var/run/mod_jk
    ~~~

1. Add read/write permissions for

    ~~~
    sudo semanage fcontext -a -t httpd_sys_rw_content_t "/var/run/mod_jk(/.*)?"
    ~~~
1. Apply the permissions

    ~~~
    sudo restorecon -R /var/run/mod_jk
    ~~~
1. Check httpd configuration, restart httpd and check if the module is enabled.
    ~~~
    sudo apachectl configtest
    sudo systemctl restart httpd
    sudo httpd -M | grep jk
        jk_module (shared)
    ~~~ 
