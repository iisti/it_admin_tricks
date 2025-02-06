# How to use PowerCLI for managing ESXi

## The First Time Usage
* On Windows open PowerShell as administrator
      
      # Install in PowerShell
      Install-Module VMware.PowerCLI
      
      # If ESXi has untrusted HTTPS certificates, allow untrusted.
      Set-PowerCLIConfiguration -InvalidCertificateAction:Ignore
      
      # Connect ESXi/vCenter, -User and -Password are optional, prompt will ask for them if they're not provided.
      Connect-VIServer -Server IP_ADDRESS -Protocol https -User USER -Password PASS
      
      # Check system information
      Get-VMHost | Format-List
