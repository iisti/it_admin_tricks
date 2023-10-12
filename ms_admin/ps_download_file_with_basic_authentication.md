# PowerShell script for downloading a file which is behind a basic authentication
  ~~~
  $Url = "https://asdf.qwerty.com/package007.zip

  # Get the package file name "package007.zip"
  $FileName = $Url -replace '(?s).*/'

  # Download the file into current user's Downloads folder
  $OutputFile = "$env:userprofile\Downloads\$FileName"

  # If one wants asked for credentials use this.
  #$Cred = Get-Credential

  # If one wants to hardcode the credentials this can be used.
  # Define clear text username and password
  [string]$UserName="user"
  [string]$UserPassword="asdfasdfasdf007!!!!"
  # Convert to securestring
  [securestring]$SecStringPassword = ConvertTo-SecureString $UserPassword -AsPlainText -Force
  # Create PSCredential object
  [pscredential]$Cred = New-Object System.Management.Automation.PSCredential ($UserName, $SecStringPassword)

  Invoke-WebRequest -Uri $Url -Credential $Cred -OutFile "$OutputFile"
  ~~~
