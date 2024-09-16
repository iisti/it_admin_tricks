# Scripts for shutting down a Windows machine

These scripts will turn off a Windows machine after a defined time. The scripts are intented to be used on machines that are needed only during certain times, e.g. business hours. There will be a pop-up asking for a confirmation and user can cancel the shutdown by answering `No` to the pop-up.

`shutdown_config.ps1` defines `$shutdownInSecs`, it determines how long should be waited before the shutdown happens. This will be shown to the user as a pop-up *The machine will be shutdown in x minutes. Do you want to proceed?*

The script should be used with Task Scheduler. The script is in 2 parts, because Task Scheduler, because if **Run wheter user is loged on or not** is selected, there will not be any pop-up for confirmation.

1st script with prompt will write `yes` into `shutdownfile.txt` if user answers `yes` to the pop-up, with no the process is viceversa.

2nd script will read the `shutdownfile.txt` and restart the VM if `yes` has been answered. If the answer has been `no`, the script will change it to `yes` and check the next scheduled time.

Check basic Task Scheduler configuration from https://github.com/iisti/it_admin_tricks_private/blob/master/ms_admin/schedule_ps_script_with_task_scheduler.md

This script specific configuration for Task Scheduler
1st task:
* Name: Shutdown with GUI prompt
* Add arguments: `-File <real_path>\shutdown_with_gui.ps1`

2nd task:
* Name: Shutdown without GUI prompt
* Add arguments: `-File <real_path>\shutdown_without_gui.ps1`

The triggers can be something like 1 minute apart, because `shutdown_config.ps1` determines how much after script execution the machine will be shutdown.

Description for both:
* The shutdown script needs two Task Scheduler tasks, because if "Run wheter user is loged on or not" is selected, there will not be any pop-up for confirmation.
"Shutdown with GUI prompt" task needs to be triggered before the "without GUI" task, so that it will indicate if the 2nd script should shutdown the machine or not.

## Give shutdown permission to non-admin user

Source https://woshub.com/allow-prevent-non-admin-users-reboot-shutdown-windows/

Premise: Windows server is running in AWS. The Windows server can be started via Jenkins by a user. When logged into the Windows server was showing only disconnect button for a user.

1. Add registry option to show the shutdown button via PowerShell
    * `REG ADD "HKLM\SOFTWARE\Microsoft\PolicyManager\default\Start\HideShutDown" /v "value" /t REG_DWORD /d 0 /f`
1. Check that the value is set
    * `Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\Start\HideShutDown"`
1. Allow user/group via local policy to shut down the server
    * Computer Configuration -> Policies -> Windows Settings -> Security Settings -> Local Policies -> User Rights Assignment -> Shut down the system
