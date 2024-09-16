# This script will shutdown a Windows machine after defined time.
# When the script is run, the shutdown can be cancelled by answering No in the pop up menu.
# shutdown_win_confirmation.ps1

##################
### INIT
##################
$script_path    = Split-Path -Parent $MyInvocation.MyCommand.Path
$logfile        = "$script_path\shutdown_with_gui.log"
$shutdownfile   = "$script_path\shutdownfile.txt"

# Import configs
. $script_path\shutdown_config.ps1

##################
### FUNCTIONS
##################

# Timestamps for logs
function Get-TimeStamp
{
    return (Get-Date (Get-Date).ToUniversalTime() -UFormat '+%Y-%m-%dT%H:%M:%S.000Z')   
}

##################
### VARIABLES
##################

# "$shutdownInSecs" is defined in shutdown_config.ps1 file.
$clockNow       = (Get-Date -Format HH:mm)
$shutdownInMins = $shutdownInSecs / 60
$title          = 'Shutdown'
$question       = "Clock is now $clockNow. This machine will shutdown in $shutdownInMins minutes. Do you want to proceed?"

##################
### SCRIPT MAIN
##################

# Write "yes" just to be sure that subsequent run will shutdown the machine if there's no confirmation,
# because it's desired the desired action.

Write-Output "yes" > $shutdownfile

if ( $null -eq ('System.Windows.MessageBox' -as [type]) ) {
    Add-Type -AssemblyName PresentationFramework
}
$msgBoxInput =  [System.Windows.MessageBox]::Show(
    "$question",
    "$title",
    'YesNo')
switch  ($msgBoxInput) 
{
    'Yes' 
    {
        Write-Output "$(Get-TimeStamp) INFO: shutdown confirmed" >> $logfile
    }
    'No' 
    {
        Write-Output "$(Get-TimeStamp) INFO: shutdown cancelled" >> $logfile
        shutdown -a
        Write-Output "no" > $shutdownfile
    }
}
