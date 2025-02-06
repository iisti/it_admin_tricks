# How to rsync from an ESXi to another

* ESXi doesn't have rsync natively
  * https://33hops.com/rsync-for-vmware-vsphere-esxi.html
  * Unzip and copy to both of the ESXi hosts and add execution permission.
      ~~~
      unzip rsync.zip
      chmod a+x Rsync
      ~~~

* A command for rsyncing VM from one ESXi to another. Log in with SSH to esxi and run something similar.
    ~~~
    rsync -av \
        --progress \
        --bwlimit=10000 \
        --rsync-path=/vmfs/volumes/datastore1/Rsync \
        root@esxi01:/vmfs/volumes/datastore1/vm01 \
        /vmfs/volumes/datastore1/
    ~~~
    * Explanations of the arguments
      ~~~
      -a                                          = archive mode; equals -rlptgoD (no -H,-A,-X)
      -v                                          = verbose
      --progress                                  = shows percentage
      --bwlimit=10000                             = Limit speed in KB/s, 10000 = 10 MB/s
      --rsync-path=/vmfs/volumes/datastore1/Rsync = This defines the location of the rsync binary of the remote ESXi.
      root@esxi01:/vmfs/volumes/datastore1/vm01   = source
      /vmfs/volumes/datastore1/                   = destination
      ~~~

## How to create alias for rsync
* cat /etc/profile.local
    ~~~
    # profile.local
    # This file is not used when UEFI secure boot is enabled.
    #
    alias rsync="/vmfs/volumes/datastore1/Rsync"
    ~~~
