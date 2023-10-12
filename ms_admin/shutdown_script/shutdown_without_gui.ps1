# This script will shutdown a Windows machine after defined time if file `shutdownfile.txt` has content `yes`.

##################
### INIT
##################
$script_path    = Split-Path -Parent $MyInvocation.MyCommand.Path
$shutdownfile   = "$script_path\shutdownfile.txt"

# Import configs
. $script_path\shutdown_config.ps1

##################
### SCRIPT MAIN
##################

if ( $(Get-Content -Path $shutdownfile) -eq "yes" ) {
    shutdown -s -t $shutdownInSecs
}
else {
    Write-Output "yes" > $shutdownfile
}
