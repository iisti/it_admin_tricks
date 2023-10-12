# Tips how to user GVIM on Windows

* https://www.vim.org/download.php
* Install with Full installtion option, so VIM will work in PowerShell
* Put VIM configurations into \__vimrc_ file in $HOME. $HOME can be checked in VIM by issuing command `:echo $HOME`
  * Issue command `:version` to check where the vimrc should reside.
  * Output into Windows userprofile
    ~~~
    curl https://gist.githubusercontent.com/iisti/bf7769f0eaa8e863e7cb0dd324b6dcf5/raw/ed4169aa875a73013ada73f71b9f8f577c2cb981/.vimrc > $env:userprofile\_vimrc
    ~~~
    * There might be an issue on line 87 `set listchars=tab:▸\ ,eol:¬` with those special characters when copy-pasting / curling.
