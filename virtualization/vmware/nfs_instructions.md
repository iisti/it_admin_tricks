# How to use NFS with ESXi

* List NFS41
    
      esxcli storage nfs41 list
      
* Add/mount NFS41

      esxcli storage nfs41 add -v <volume-name> -H <hostname.domain> -s <mount-point i.e /mnt/pool01/backups>

* Remove NFS41 storage

      esxcli storage nfs41 remove -v <volume-name>
      
## Remount NFS41

      esxcli storage nfs41 list
      Volume Name        Host(s)                      Share                Accessible  Mounted  Read-Only  Security   isPE  Hardware Acceleration
      -----------------  ---------------------------  -------------------  ----------  -------  ---------  --------  -----  ---------------------
      freenas01-backups  freenas01                    /mnt/pool01/backups       false    false      false  AUTH_SYS  false  Unknown

      esxcli storage nfs41 remove -v freenas01-backups
      esxcli storage nfs41 add -v freenas01-backups -H freenas01 -s /mnt/pool01/backups

      esxcli storage nfs41 list
      Volume Name        Host(s)                      Share                Accessible  Mounted  Read-Only  Security   isPE  Hardware Acceleration
      -----------------  ---------------------------  -------------------  ----------  -------  ---------  --------  -----  ---------------------
      freenas01-backups  freenas01                    /mnt/pool01/backups        true     true      false  AUTH_SYS  false  Not Supported


      
