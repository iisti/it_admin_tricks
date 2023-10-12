# Scripts for shutting down a Windows machine

These scripts will turn off a Windows machine after a defined time. The scripts are intented to be used on machines that are needed only during certain times, e.g. business hours. There will be a pop-up asking for a confirmation and user can cancel the shutdown by answering `No` to the pop-up.

The script should be used with Task Scheduler. The script is in 2 parts, because Task Scheduler, because if "Run wheter user is loged on or not" is selected, there will not be any pop-up for confirmation.

1st script with prompt will write `yes` into `shutdownfile.txt` if user answers `yes` to the pop-up, with no the process is viceversa.
2nd script will read the `shutdownfile.txt` and restart the VM if `yes` has been answered. If the answer has been `no`, the script will change it to `yes` and check the next scheduled time. 

Check basic Task Scheduler configuration from https://github.com/iisti/it_admin_tricks_private/blob/master/ms_admin/schedule_ps_script_with_task_scheduler.md

This script specific configuration for Task Scheduler
1st task:
Name: Shutdown with GUI prompt
Add arguments: `-File <real_path>\shutdown_with_gui.ps1`

2nd task:
Name: Shutdown without GUI prompt
Add arguments: `-File <real_path>\shutdown_without_gui.ps1`

Description for both:
The shutdown script needs two Task Scheduler tasks, because if "Run wheter user is loged on or not" is selected, there will not be any pop-up for confirmation.
"Shutdown with GUI prompt" task needs to be triggered before the "without GUI" task, so that it will indicate if the 2nd script should shutdown the machine or not.
