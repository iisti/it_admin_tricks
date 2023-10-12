# Tips to remove files via PowerShell

## Remove files/folders recursively fast in PowerShell with CMD command
* Pure PowerShell commands have ofter errors with recursive. I've found that this is the fastest way to remove a lot lot of files.
    ~~~
    cmd /c "rd /s /q c:\to_be_removed_dir"
    ~~~

## Remove files with *pattern* in PowerShell
* Storage software created duplicate files and included ***(User Name)*** in the file names of duplicated items. These commands help to remove the duplicates.
* Works with PowerShell 7.1, ***doesn't work correctly with PowerShell 5.1***

1. Go to the root folder which has the duplicate files.
    ~~~
    cd X:\conflicting_folder
    ~~~
1. Check duplicates
    ~~~
    Get-ChildItem -LiteralPath $(Get-Location) -File -Include "*(User Name)*" -Recurse | Write-Host
    ~~~
1. Remove duplicates
    ~~~
    Get-ChildItem -LiteralPath $(Get-Location) -File -Include "*(Usern Name)*" -Recurse | Remove-Item -Force -Verbose
    ~~~
    
## Remove empty directories recursively via PowerShell

* Source for script: https://stackoverflow.com/questions/28631419/how-to-recursively-remove-all-empty-folders-in-powershell

* PowerShell script, save as .ps1 file and run
    ~~~
    # Check that path is given as a parameter, exit if not.
    if (!$args[0]) {
      Write-Host "Path parameter was not given, can't run the script!"
      Write-Host "Run the script: script path"
      exit
      }

    $tdc=$args[0]

    # Added -attributes !H to the original script, so hidden files are skipped
    # Added -Recurse to Remove-Item, so that confirmation is not asked.
    # Source: https://zacheryolinske.wordpress.com/2017/11/27/powershell-remove-item-with-confirm-prompt/
    do {
      $dirs = gci $tdc -directory -recurse | Where { (gci $_.fullName).count -eq 0 } | select -expandproperty FullName
      $dirs | Foreach-Object { Remove-Item $_ -Recurse}
    } while ($dirs.count -gt 0)
    ~~~
