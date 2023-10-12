# Stop services

# Run by running command:
# powershell.exe -noprofile -executionpolicy bypass -file c:\01-install\services_stop.ps1

# Check service names with command
# Get-Service -DisplayName serviecname* | Format-List

Stop-Service -Name "servicename"

# Set StartupType Disabled if needed.
Set-Service -StartupType Disabled -Name "servicename"
