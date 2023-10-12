# How to schedule a PowerShell script with Task Scheduler
1. Open Task Scheduler
2. Action -> Create Task...
3. In General tab
  1. Add Name
  1. Run whether user is logged on or not
  1. Run with highest privileges
4. Triggers tab
    * This configuration runs every 2 hours
      ~~~
      Begin the task:       On a schedule
      One time:             Put a date that is in the past.
      Repeat task every:    2 hours
        for a duration of:  Indefinitely
      Enabled:              checked
      ~~~
1. Actions tab
    ~~~
    Action:                   Start a Program
    Program/script:           powershell
    Add arguments (optional): -File C:\path\script_name.ps1
    ~~~
1. Conditions tab
    * Defaults
1. Settings tab
    * Checked (these were defaults)
    ~~~
    Allow task to bew run on demand
    Stop the task if it runs longer than 3 days
    If the running task does not end when requrested, force it to stop
    ~~~
