# rsync tips

## A script for rsyncing if the path is mounted
* Save as rsync_if_mounted.bash
    ~~~
    #!/usr/bin/env bash

    # A script for checking if a path is mounted and then running a command.
    # Syntax:
    # rsync_if_mounted.bash /some/path/to/mount "Command to run if mounted"

    # Source for checking if mounted: https://serverfault.com/a/901858/323362

    # These functions return exit codes: 0 = found, 1 = not found
    func_is_mounted     () { findmnt -rno SOURCE,TARGET "$1" >/dev/null;} #path or device
    func_is_dev_mounted () { findmnt -rno SOURCE        "$1" >/dev/null;} #device only
    func_is_path_mounted() { findmnt -rno        TARGET "$1" >/dev/null;} #path   only
    # where: -r = --raw, -n = --noheadings, -o = --output

    if func_is_mounted "$1";
        then
            $2
        else
            echo "ERROR: $1 is not mounted"
    fi
    ~~~

    * Example of running the script
    ~~~
    sudo ./rsync_if_mounted.bash /opt/nfs_backup "rsync -rtv --progress --log-file=/var/log/rsync/rsync.log /opt/storage/files/ /opt/nfs_backup/files_2021/"
    ~~~

## Create log folder and logrotete for rsync

* Log folder creation
    ~~~
    sudo mkdir /var/log/rsync
    ~~~

* Log rotate configuration file `/etc/logrotate.d/rsynclog`
    * https://linux.die.net/man/8/logrotate
    ~~~
    /var/log/rsync/*.log {
        rotate 10
        size=5k
        copytruncate
        compress
        missingok
        notifempty
    }
    ~~~
    * With this one can use option `--log-file=/var/log/rsync/whatever_rsync.log` and the log will be rotated automatically.

## Remove source files and empty folders after successfull transfer
* Rsync doesn't remove source folders by default if option --remove-source-files is used, so one needs to add another command to achieve it.
* Note that only empty folders are removed.
~~~
sudo rsync -zrtv \
    --progress \
    --remove-source-files \
    /mnt/source-dir \
    "/mnt/f/destination-dir/" && \
    find /mnt/source-dir -depth -type d -empty -not -path some_dir -delete
~~~
