# Create shortcut to a PowerShell script which can be launched as administrator

1. Create shortcut by right click mouse click inside the location where shortcut is reqruired -> New -> Shortcut
1. Set target as something similar as below

    ~~~PowerShell
    "C:\Program Files\PowerShell\7\pwsh.exe" -NoExit C:\01-install\scripts\script.ps1
    ~~~

    * -NoExit = prevents the PowerShell window from closing after running the script, so the result can be seen.

1. Now one can right click on the shortcut an choose `Run as administrator`
