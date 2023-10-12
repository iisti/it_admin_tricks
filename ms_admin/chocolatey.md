# Automating installing basic software with Chocolatey package manager
* https://chocolatey.org/install

## Installation of Chocolatey on Windows
* On Administrator PowerShell
~~~
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
~~~

## Basic packages
* Win 10
    ~~~
    choco install firefox googlechrome 7zip.install notepadplusplus.install winscp putty powershell-core vim microsoft-windows-terminal
    ~~~

* Win 11
    ~~~
    choco install firefox googlechrome 7zip.install notepadplusplus.install winscp putty powershell-core vim
    ~~~

* Server
    ~~~
    choco install firefox googlechrome 7zip.install notepadplusplus.install winscp putty powershell-core vim
    ~~~
