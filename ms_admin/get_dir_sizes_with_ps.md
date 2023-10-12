# Check directory sizes with PowerShell

* Source: http://woshub.com/powershell-get-folder-sizes/

* PowerShell script, save as .ps1 file and run.
    ~~~
    # Check that path is given as a parameter, exit if not.
    if (!$args[0]) {
      Write-Host "Path parameter was not given, can't run the script!"
      Write-Host "Run the script: script path"
      exit
      }

    $targetfolder=$args[0]

    $dataColl = @()
    gci -force $targetfolder -ErrorAction SilentlyContinue | ? { $_ -is [io.directoryinfo] } | % {
    $len = 0
    gci -recurse -force $_.fullname -ErrorAction SilentlyContinue | % { $len += $_.length }
    $foldername = $_.fullname
    $foldersize= '{0:N2}' -f ($len / 1Gb)
    $dataObject = New-Object PSObject
    Add-Member -inputObject $dataObject -memberType NoteProperty -name “foldername” -value $foldername
    Add-Member -inputObject $dataObject -memberType NoteProperty -name “foldersizeGb” -value $foldersize
    $dataColl += $dataObject
    }
    $dataColl | Out-GridView -Title "Size of subdirectories"
    ~~~
