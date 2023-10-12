# Robocopy tips

## Robocopy folder and contents
* By default robocopy copies only the contents of a folder
    ~~~
    $folder="folder_name"
    robocopy c:\stuff\$folder d:\backup\$folder /e /dcopy:t
    ~~~

## Backup a folder script
* PowerShell script
* ATTENTION CHECK if this is copying only the contents and not the dir_to_backup also!
    ~~~powershell
    # Variable for logging date in log file name
    $ReportDate = (Get-Date).tostring("dd-MM-yyyy_hh-mm-ss")

    # Robocopy /b = backup mode /e = include subdirs
    Robocopy "C:\dir_to_backup" "D:\backups" /b /e /log+:"D:\backups\robocopy-logs\log_robocopy_$ReportDate.txt"

    ### Remove log files older than 15 days ###
    $limit = (Get-Date).AddDays(-15)
    $path = "D:\backups\robocopy-logs"

    # Delete files older than the $limit.
    Get-ChildItem -Path $path -Recurse -Force | Where-Object { !$_.PSIsContainer -and $_.CreationTime -lt $limit } | Remove-Item -Force
    ~~~
    
## Copy a list of folders
* PowerShell script. You need to be in the parent of dir01 and dir02, otherwise change the paths.
    ~~~powershell
    # Add folders to list
    $vm_list = "vm01","vm02"
    # Print the list
    $vm_list | foreach-object {write-host $_}
    # Copy the folders and their contents
    $vm_list | foreach-object { robocopy .\$_ "d:\vm backups\$_" /e }
    ~~~
    
## Network share in PowerShell
* Add network share into share into PowerShell, so one can robocopy into it.
~~~
$cred = Get-Credential -Credential user
new-psdrive -name "Z" -root "\\nfs.server.com\backups" -persist -psprovider 'filesystem' -credential $cred
~~~

