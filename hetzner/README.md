# Hetzner Cloud Instructions

## Hetzner + Kubernetes

Check [Hetzner Kubernetes instructions](../kubernetes/hetzner/README.md)

## HCloud CLI

* <https://github.com/hetznercloud/cli>

### Useful commands for Terraform automation

* List images

    ~~~sh
    hcloud image list
    ~~~

* List server types

    ~~~sh
    hcloud server-type list
    ~~~

## Storage Box

### Mount Hetzner Storage Box on Rocky Linux 9

~~~sh
mkdir /mnt/sb-20tb

# Test mount
mount.cifs -o seal,user=u123456-sub1,pass=<password> //u123456.your-storagebox.de/u123456-sub1 /mnt/sb-20tb

# Unmount the test
umount //u123456.your-storagebox.de/u123456-sub1

# /etc/fstab
//u123456-sub1.your-storagebox.de/u123456-sub1 /mnt/sb-20tb cifs iocharset=utf8,rw,seal,credentials=/root/.credentials-sb-20tb.txt,uid=<linux_user_id>,gid=<linux_group_id>,file_mode=0660,dir_mode=0770 0 0

# Create credentials file /root/.credentials-sb-20tb.txt
username=<username>
password=<password>

# Change permissions
chmod 0400 /root/.credentials-sb-20tb.txt

# Mount via fstab
mount -a
~~~
