# Bash script for removing files older than x days

* If one wants to use /var/log and logrotate with the script, configure the below.
  * One can also change the script that the logs are written into some other folder.
    ~~~
    # Create directory for the logs
    mkdir /var/log/cleanups
    # Depending on the security required, this could be also less permissive.
    # Permission 777 allows that any user running the cleanup script can log into /var/log/cleanups.
    chmod -R 777 /var/log/cleanups

    # Create logrotate file
    vim /etc/logrotate.d/cleanups

    /var/log/cleanups/*.log {
        rotate 10
        size=5k
        copytruncate
        compress
        missingok
        notifempty
    }
    ~~~

## A script for removing files that haven't been accessed over certain time.
  * One can change the arguments atime / mtime depending if access or modification time is wanted want to be the factor which determines when file is removed.
    ~~~
    #!/usr/bin/env bash
    
    ##############
    ### Some info
    ##############
    
    # find argument explanantions
    # atime = last accessed time
    # mtime = last modification time, contents of the file have been modified
    # ctime = last change time, file's properties (e.g. permissions, name)  have been changed
    # crtime = creation time

    # Things to remember:
    #   atime can update itself
    #   When ctime updates, atime updates
    #   When mtime updates, ctime and atime update

    # Checking timestamps from shell
    # ls -l         = gives mtime
    # ls -lu        = gives atime
    # ls -lc        = gives ctime
    # stat file.txt = gives all data in one go


    ##########################
    ### VARIABLES / CONSTANTS
    ##########################

    # If one wants to use /var/log/ and logrotate for log files,
    # then one doesn't need these constants.
    # Enable log removal also from the end of the script if not using logrotate.
    #readonly DATE_FILE=$(date '+%Y-%m-%d')
    #readonly LOGFILE="$LOGDIR"/"$DATE_FILE"_cleanup.log

    # If one uses the /var/log for logs,
    # create logrotate file also.
    readonly LOGDIR=/var/log/cleanups
    readonly LOGFILE="$LOGDIR"/cleanup.log

    # Root directory for searching old files.
    readonly SEARCHPATH=/home/iisti/test_removal

    # Constant for determining how old files should be searched.
    readonly TIMESPAN="+3"
    # Constant which determines how old logs should be saved.
    # This doesn't do anything if logrotate is in use.
    readonly LOGTIMESPAN="+14"


    ################
    ### MAIN SCRIPT
    ################

    echo "$(date --iso-8601=seconds) ### Script started" >> "$LOGFILE"
    echo "Searching for files that have not been accessed since "$TIMESPAN" days" >> "$LOGFILE"

    # Find files and log them
    find "$SEARCHPATH" -type f -atime "$TIMESPAN" -print >> "$LOGFILE"

    # Remove files and log the operation
    echo "Removing the files listed above" >> "$LOGFILE"
    find "$SEARCHPATH" -type f -atime "$TIMESPAN" -exec rm {} \; >> "$LOGFILE"

    # One can also remove empty directories if needed.
    #echo 'Searching for empty folders' >> "$LOGFILE"
    #find "$SEARCHPATH" -mindepth 1 -empty -type d >> "$LOGFILE"
    #find "$SEARCHPATH" -mindepth 1 -empty -type d -delete >> "$LOGFILE"

    # If one doesn't use /var/log + logrotation,
    # then one can remove olds with log timespan.
    #find $LOGDIR -type f -mtime "$LOGTIMESPAN" -exec rm {} \;
    
    echo "$(date --iso-8601=seconds) ### Script ended" >> "$LOGFILE"
    ~~~

## A script for removing files by modification date, but leave certain amount of files regardless of the date
* This script is designed to leave certain amount of files on disk even if they're older than what shold be removed.
  * This is good for removing old backups, but still leaving the newest ones.
   ~~~
   #!/usr/bin/env bash

   ##############
   ### Some info
   ##############

   # find argument explanantions
   # atime = last accessed time
   # mtime = last modification time, contents of the file have been modified
   # ctime = last change time, file's properties (e.g. permissions, name)  have been changed
   # crtime = creation time

   # Things to remember:
   #   atime can update itself
   #   When ctime updates, atime updates
   #   When mtime updates, ctime and atime update

   # Checking timestamps from shell
   # ls -l         = gives mtime
   # ls -lu        = gives atime
   # ls -lc        = gives ctime
   # stat file.txt = gives all data in one go


   ##############
   ### CONSTANTS
   ##############

   # If one wants to use /var/log/ and logrotate for log files,
   # then one doesn't need these constants.
   # Enable log removal also from the end of the script if not using logrotate.
   #readonly DATE_FILE=$(date '+%Y-%m-%d')
   #readonly LOGFILE="$LOGDIR"/"$DATE_FILE"_cleanup.log

   # If one uses the /var/log for logs,
   # create logrotate file also.
   readonly LOGDIR=/var/log/cleanups
   readonly LOGFILE="$LOGDIR"/cleanup.log

   # Root directory for searching old files.
   readonly SEARCHPATH=/home/iisti/test_removal

   # Constant for determining how old files should be removed.
   readonly TIMESPAN=1

   # How many files should be left.
   readonly SAVE_FILE_AMOUNT="2"

   # Constant which determines how old logs should be saved.
   # This doesn't do anything if logrotate is in use.
   readonly LOGTIMESPAN="+14"


   ###############################################
   # CONSTANTS WHICH SHOULD NOT BE CHANED BY USER
   ###############################################

   # A helper variable, becase "tail -n +N" starts to print from line number N before the end,
   # so line N might be removed, if it's too old file. Let's add +1 into N, so that N number
   # of lines/files are left on the disk.
   readonly leave_files="+$(expr $SAVE_FILE_AMOUNT + 1)"

   # This gives the date in seconds since 1970-01-01 00:00:00 UTC minus the amount of days
   # files should stay on the disk.
   readonly TIMESPAN_SINCE=$(date -d "$TIMESPAN days ago" '+%s')


   ################
   ### MAIN SCRIPT
   ################

   echo "$(date --iso-8601=seconds) ### Script started" >> "$LOGFILE"

   # Explanations of the removal process:
   # stat -c "%Y %n" prints:
   #       %Y = Time of last modification as seconds since Epoch
   #       %n = File name
   # sort -nr
   #       Sorts stat output from youngest (begin of print) till the oldest.
   # tail -n +N
   #   Outputs the tail from the +N line. These files will be removed if they're too old.
   # while read -r
   #       Read the output to mtime and name variables.

   echo "    Remove files if modification day is older than: $TIMESPAN" >> "$LOGFILE"
   echo "    How many files should be left: $SAVE_FILE_AMOUNT" >> "$LOGFILE"
   echo "Removing files. If no file names are printed, nothing is removed." >> "$LOGFILE"
   stat -c "%Y %n" "$SEARCHPATH"/* | sort -nr | tail -n "$leave_files" | while read -r mtime name; do
       if (( mtime < "$TIMESPAN_SINCE" )); then
           echo "    $name" >> "$LOGFILE"
           rm $name
       fi
   done


   # One can also remove empty directories if needed.
   #echo 'Searching for empty folders' >> "$LOGFILE"
   #find "$SEARCHPATH" -mindepth 1 -empty -type d >> "$LOGFILE"
   #find "$SEARCHPATH" -mindepth 1 -empty -type d -delete >> "$LOGFILE"

   # If one doesn't use /var/log + logrotation,
   # then one can remove olds with log timespan.
   #find $LOGDIR -type f -mtime "$LOGTIMESPAN" -exec rm {} \;

   echo "$(date --iso-8601=seconds) ### Script ended" >> "$LOGFILE"
   ~~~
