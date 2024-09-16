# Entra ID (formerly AzureAD) Instructions



## RDP into laptop which is connected to Entra ID

Sources
* https://stackoverflow.com/questions/62307900/remote-machine-is-aad-but-the-logon-attempt-failed
* https://answers.microsoft.com/en-us/windows/forum/all/remove-pin-sign-in-has-no-option-to-remove/08c6367b-621e-41a2-b290-adb75ea38d92

### On the laptop which is RDP'd into 

1. Check if the laptop is in Entra ID via PowerShell

   ~~~PowerShell
   dsregcmd /status
   ~~~
   * There's a line `AzureADJoined : Yes`
   
1. Enable RDP in the laptop
1. Disable NLA (Network Level Authentication)
1. For some reason Hello PIN required reset, otherwise login didn't work.
    1. Press Windows+X and select Windows PowerShell(Admins)
    1. Paste the command below and press Enter
  
        ~~~PowerShell
        powershell -windowstyle hidden -command "Start-Process cmd -ArgumentList '/s,/c,takeown /f C:\Windows\ServiceProfiles\LocalService\AppData\Local\Microsoft\NGC /r /d y & icacls C:\Windows\ServiceProfiles\LocalService\AppData\Local\Microsoft\NGC /grant administrators:F /t & RD /S /Q C:\Windows\ServiceProfiles\LocalService\AppData\Local\Microsoft\Ngc & MD C:\Windows\ServiceProfiles\LocalService\AppData\Local\Microsoft\Ngc & icacls C:\Windows\ServiceProfiles\LocalService\AppData\Local\Microsoft\Ngc /T /Q /C /RESET' -Verb runAs"
        ~~~
      
    1. Restart the computer and try to reconfigure the Windows Hello input methods.

### On the machine that one wants to RDP'd from

1. Open RDP login window
1. Configure
    * Computer: IP or hostname (hostname can be set in hosts file)
    * Username: `azuread\firstlastname` (for example azuread\lukeskywalker)
1. Save the RDP configuration file and open the file with text editor.
1. Add line `enablecredsspsupport:i:0` into the file.
1. Now RDP should work.
