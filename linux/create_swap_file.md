# Creating a swap file in Rocky Linux
* OS Rocky Linux 8
* VM runs in AWS
1. Swap file size
    * Swap file size will be 16 GB, 16 * 1024 MB = 16384 MB
    * count: 16384 MB / 128 MB = 128
    ~~~
    sudo dd if=/dev/zero of=/swapfile bs=128M count=128
    ~~~
1. Update read/write permissions
    ~~~
    sudo chmod 600 /swapfile
    ~~~
1. Set up a the swap file
    ~~~
    sudo mkswap /swapfile
    ~~~
1. Make swap file available
    ~~~
    sudo swapon /swapfile
    ~~~
1. Verify that process was successful
    ~~~
    sudo swapon -s
    ~~~
1. Edit /etc/fstab
    * vim /etc/fstab 
    ~~~
    /swapfile swap swap defaults 0 0
    ~~~
